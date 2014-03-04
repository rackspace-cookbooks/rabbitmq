#
# Cookbook Name:: rabbitmq
# Provider:: vhost
#
# Copyright 2011-2013, Opscode, Inc.
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

def vhost_exists?(name)
  cmdstr = "rabbitmqctl -q list_vhosts | grep ^#{name}$"
  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.environment['HOME'] = ENV.fetch('HOME', '/root')
  cmd.run_command
  Chef::Log.debug "rabbitmq_vhost_exists?: #{cmdstr}"
  Chef::Log.debug "rabbitmq_vhost_exists?: #{cmd.stdout}"
  begin
    cmd.error!
    true
  rescue
    false
  end
end

action :add do
  unless vhost_exists?(new_resource.vhost)
    cmdstr = "rabbitmqctl add_vhost #{new_resource.vhost}"
    execute cmdstr do
      Chef::Log.debug "rabbitmq_vhost_add: #{cmdstr}"
      Chef::Log.info "Adding RabbitMQ vhost '#{new_resource.vhost}'."
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if vhost_exists?(new_resource.vhost)
    cmdstr =  "rabbitmqctl delete_vhost #{new_resource.vhost}"
    execute cmdstr do
      Chef::Log.debug "rabbitmq_vhost_delete: #{cmdstr}"
      Chef::Log.info "Deleting RabbitMQ vhost '#{new_resource.vhost}'."
      new_resource.updated_by_last_action(true)
    end
  end
end
