#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2009, Benjamin Black
# Copyright 2009-2013, Opscode, Inc.
# Copyright 2012, Kevin Nuckolls <kevin.nuckolls@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'erlang'

## Install the package
case node['platform_family']
when 'debian'
  # installs the required setsid command -- should be there by default but just in case
  package 'util-linux'

  if node['rackspace_rabbitmq']['use_distro_version']
    package 'rabbitmq-server'
  else
    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rackspace_rabbitmq']['version']}-1_all.deb" do
      source node['rackspace_rabbitmq']['package']
      action :create_if_missing
    end
    dpkg_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rackspace_rabbitmq']['version']}-1_all.deb"
  end

  # Configure job control
  if node['rackspace_rabbitmq']['job_control'] == 'upstart'
    # We start with stock init.d, remove it if we're not using init.d, otherwise leave it alone
    service node['rackspace_rabbitmq']['service_name'] do
      action [:stop]
      only_if { File.exist?('/etc/init.d/rabbitmq-server') }
    end

    execute 'remove rabbitmq init.d command' do
      command 'update-rc.d -f rabbitmq-server remove'
    end

    file '/etc/init.d/rabbitmq-server' do
      action :delete
    end

    template "/etc/init/#{node['rackspace_rabbitmq']['service_name']}.conf" do
      source 'rabbitmq.upstart.conf.erb'
      owner 'root'
      group 'root'
      mode 0644
      variables(max_file_descriptors: node['rackspace_rabbitmq']['max_file_descriptors'])
    end

    service node['rackspace_rabbitmq']['service_name'] do
      provider Chef::Provider::Service::Upstart
      action [:enable, :start]
      # restart_command "stop #{node['rackspace_rabbitmq']['service_name']} && start #{node['rackspace_rabbitmq']['service_name']}"
    end
  end

  ## You'll see setsid used in all the init statements in this cookbook. This
  ## is because there is a problem with the stock init script in the RabbitMQ
  ## debian package (at least in 2.8.2) that makes it not daemonize properly
  ## when called from chef. The setsid command forces the subprocess into a state
  ## where it can daemonize properly. -Kevin (thanks to Daniel DeLeo for the help)
  service node['rackspace_rabbitmq']['service_name'] do
    start_command 'setsid /etc/init.d/rabbitmq-server start'
    stop_command 'setsid /etc/init.d/rabbitmq-server stop'
    restart_command 'setsid /etc/init.d/rabbitmq-server restart'
    status_command 'setsid /etc/init.d/rabbitmq-server status'
    supports status: true, restart: true
    action [:enable, :start]
    only_if { node['rackspace_rabbitmq']['job_control'] == 'initd' }
  end

when 'rhel', 'fedora'
  # This is needed since Erlang Solutions' packages provide "esl-erlang"; this package just requires "esl-erlang" and provides "erlang".
  if node['erlang']['install_method'] == 'esl'
    remote_file "#{Chef::Config[:file_cache_path]}/esl-erlang-compat.rpm" do
      source 'https://github.com/jasonmcintosh/esl-erlang-compat/blob/master/rpmbuild/RPMS/noarch/esl-erlang-compat-R14B-1.el6.noarch.rpm?raw=true'
    end
    rpm_package "#{Chef::Config[:file_cache_path]}/esl-erlang-compat.rpm"
  end

  if node['rackspace_rabbitmq']['use_distro_version']
    package 'rabbitmq-server'
  else
    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rackspace_rabbitmq']['version']}-1.noarch.rpm" do
      source node['rackspace_rabbitmq']['package']
      action :create_if_missing
    end
    rpm_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rackspace_rabbitmq']['version']}-1.noarch.rpm"
  end

  service node['rackspace_rabbitmq']['service_name'] do
    action [:enable, :start]
  end

when 'suse'
  # rabbitmq-server-plugins needs to be first so they both get installed
  # from the right repository. Otherwise, zypper will stop and ask for a
  # vendor change.
  package 'rabbitmq-server-plugins'
  package 'rabbitmq-server'

  service node['rackspace_rabbitmq']['service_name'] do
    action [:enable, :start]
  end
when 'smartos'
  package 'rabbitmq'

  service 'epmd' do
    action :start
  end

  service node['rackspace_rabbitmq']['service_name'] do
    action [:enable, :start]
  end
end

directory node['rackspace_rabbitmq']['logdir'] do
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '775'
  recursive true
  only_if { node['rackspace_rabbitmq']['logdir'] }
end

directory node['rackspace_rabbitmq']['mnesiadir'] do
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '775'
  recursive true
end

template "#{node['rackspace_rabbitmq']['config_root']}/rabbitmq-env.conf" do
  source 'rabbitmq-env.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rackspace_rabbitmq']['service_name']}]"
end

template "#{node['rackspace_rabbitmq']['config_root']}/rabbitmq.config" do
  source 'rabbitmq.config.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rackspace_rabbitmq']['service_name']}]"
end

if File.exist?(node['rackspace_rabbitmq']['erlang_cookie_path'])
  existing_erlang_key =  File.read(node['rackspace_rabbitmq']['erlang_cookie_path']).strip
else
  existing_erlang_key = ''
end

if node['rackspace_rabbitmq']['cluster'] && (node['rackspace_rabbitmq']['erlang_cookie'] != existing_erlang_key)
  log "stopping service[#{node['rackspace_rabbitmq']['service_name']}] to change erlang_cookie" do
    level :info
    notifies :stop, "service[#{node['rackspace_rabbitmq']['service_name']}]", :immediately
  end

  template node['rackspace_rabbitmq']['erlang_cookie_path'] do
    source 'doterlang.cookie.erb'
    owner 'rabbitmq'
    group 'rabbitmq'
    mode 00400
    notifies :start, "service[#{node['rackspace_rabbitmq']['service_name']}]", :immediately
    notifies :run, 'execute[reset-node]', :immediately
  end

  # Need to reset for clustering #
  execute 'reset-node' do
    command 'rabbitmqctl stop_app && rabbitmqctl reset && rabbitmqctl start_app'
    action :nothing
  end
end
