#
# Cookbook Name:: rabbitmq
#
# Copyright 2014, Rackspace, UK, Ltd.
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

require 'spec_helper'

describe 'rackspace_rabbitmq::default' do
  rackspace_rabbitmq_test_platforms.each do |platform, versions|
    describe "on #{platform}" do
      versions.each do |version|
        describe version do
          before :each do
            stub_command('test -f /var/run/rabbitmq.pid').and_return(true)
            stub_command('tar zxf /var/chef/cache/apache-rabbitmq-5.8.0-bin.tar.gz').and_return(true)
          end
          let(:chef_run) do
            runner = ChefSpec::Runner.new(platform: platform.to_s, version: version.to_s)
            runner.converge('rackspace_rabbitmq::default')
          end
          it 'include the default recipe' do
            expect(chef_run).to include_recipe 'rackspace_rabbitmq::default'
          end
          it 'creates the template' do
            expect(chef_run).to create_template('/etc/rabbitmq/rabbitmq.config')
          end
          it 'creates the template' do
            expect(chef_run).to create_template('/etc/rabbitmq/rabbitmq-env.conf')
          end
          it 'populate the /var/log/rabbitmq directory' do
            expect(chef_run).to create_directory('/var/log/rabbitmq')
          end
          it 'populate the /var/lib/rabbitmq/mnesia directory' do
            expect(chef_run).to create_directory('/var/lib/rabbitmq/mnesia')
          end
          it 'create remote file /var/chef/cache/rabbitmq-server_3.1.5-1_all.deb' do
            expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/rabbitmq-server_3.1.5-1_all.deb')
          end
          it 'installs erlang-nox package' do
            expect(chef_run).to install_package('erlang-nox')
          end
          it 'installs erlang-dev package' do
            expect(chef_run).to install_package('erlang-dev')
          end
          it 'installs util-linux package' do
            expect(chef_run).to install_package('util-linux')
          end
          it 'installs /var/chef/cache/rabbitmq-server_3.1.5-1_all.deb' do
            expect(chef_run).to install_dpkg_package('/var/chef/cache/rabbitmq-server_3.1.5-1_all.deb')
          end
          it 'enable service rabbitmq-server' do
            expect(chef_run).to enable_service('rabbitmq-server')
          end
        end
      end
    end
  end
end
