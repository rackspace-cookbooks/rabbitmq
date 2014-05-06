# Latest RabbitMQ.com version to install
default['rackspace_rabbitmq']['version'] = '3.1.5'
# The distro versions may be more stable and have back-ported patches
default['rackspace_rabbitmq']['use_distro_version'] = false

# being nil, the rabbitmq defaults will be used
default['rackspace_rabbitmq']['nodename']  = nil
default['rackspace_rabbitmq']['address']  = nil
default['rackspace_rabbitmq']['port']  = nil
default['rackspace_rabbitmq']['config'] = nil
default['rackspace_rabbitmq']['logdir'] = '/var/log/rabbitmq'
default['rackspace_rabbitmq']['mnesiadir'] = '/var/lib/rabbitmq/mnesia'
default['rackspace_rabbitmq']['service_name'] = 'rabbitmq-server'

# config file location
# http://www.rabbitmq.com/configure.html#define-environment-variables
# "The .config extension is automatically appended by the Erlang runtime."
default['rackspace_rabbitmq']['config_root'] = '/etc/rabbitmq'
default['rackspace_rabbitmq']['config'] = '/etc/rabbitmq/rabbitmq'
default['rackspace_rabbitmq']['erlang_cookie_path'] = '/var/lib/rabbitmq/.erlang.cookie'

# rabbitmq.config defaults
default['rackspace_rabbitmq']['default_user'] = 'guest'
default['rackspace_rabbitmq']['default_pass'] = 'guest'

# bind erlang networking to localhost
default['rackspace_rabbitmq']['local_erl_networking'] = false

# bind rabbit and erlang networking to an address
default['rackspace_rabbitmq']['erl_networking_bind_address'] = nil

# clustering
default['rackspace_rabbitmq']['cluster'] = false
default['rackspace_rabbitmq']['cluster_disk_nodes'] = []
default['rackspace_rabbitmq']['erlang_cookie'] = 'AnyAlphaNumericStringWillDo'

# resource usage
default['rackspace_rabbitmq']['disk_free_limit_relative'] = nil
default['rackspace_rabbitmq']['vm_memory_high_watermark'] = nil
default['rackspace_rabbitmq']['max_file_descriptors'] = 1024
default['rackspace_rabbitmq']['open_file_limit'] = nil

# job control
default['rackspace_rabbitmq']['job_control'] = 'initd'

# ssl
default['rackspace_rabbitmq']['ssl'] = false
default['rackspace_rabbitmq']['ssl_port'] = 5671
default['rackspace_rabbitmq']['ssl_cacert'] = '/path/to/cacert.pem'
default['rackspace_rabbitmq']['ssl_cert'] = '/path/to/cert.pem'
default['rackspace_rabbitmq']['ssl_key'] = '/path/to/key.pem'
default['rackspace_rabbitmq']['ssl_verify'] = 'verify_none'
default['rackspace_rabbitmq']['ssl_fail_if_no_peer_cert'] = false
default['rackspace_rabbitmq']['web_console_ssl'] = false
default['rackspace_rabbitmq']['web_console_ssl_port'] = 15_671

# tcp listen options
default['rackspace_rabbitmq']['tcp_listen_packet'] = 'raw'
default['rackspace_rabbitmq']['tcp_listen_reuseaddr']  = true
default['rackspace_rabbitmq']['tcp_listen_backlog'] = 128
default['rackspace_rabbitmq']['tcp_listen_nodelay'] = true
default['rackspace_rabbitmq']['tcp_listen_exit_on_close'] = false
default['rackspace_rabbitmq']['tcp_listen_keepalive'] = false

# virtualhosts
default['rackspace_rabbitmq']['virtualhosts'] = []
default['rackspace_rabbitmq']['disabled_virtualhosts'] = []

# users
default['rackspace_rabbitmq']['enabled_users'] =
  [{ name: 'guest', password: 'guest', rights:     [{ vhost: nil , conf: '.*', write: '.*', read: '.*' }]
  }]
default['rackspace_rabbitmq']['disabled_users'] = []

# plugins
default['rackspace_rabbitmq']['enabled_plugins'] = []
default['rackspace_rabbitmq']['disabled_plugins'] = []

# platform specific settings
case node['platform_family']
when 'debian'
  default['rackspace_rabbitmq']['package'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rackspace_rabbitmq']['version']}/rabbitmq-server_#{node['rackspace_rabbitmq']['version']}-1_all.deb"
when 'rhel', 'fedora'
  default['rackspace_rabbitmq']['package'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rackspace_rabbitmq']['version']}/rabbitmq-server-#{node['rackspace_rabbitmq']['version']}-1.noarch.rpm"
when 'smartos'
  default['rackspace_rabbitmq']['service_name'] = 'rabbitmq'
  default['rackspace_rabbitmq']['config_root'] = '/opt/local/etc/rabbitmq'
  default['rackspace_rabbitmq']['config'] = '/opt/local/etc/rabbitmq/rabbitmq'
  default['rackspace_rabbitmq']['erlang_cookie_path'] = '/var/db/rabbitmq/.erlang.cookie'
end

# Example HA policies
default['rackspace_rabbitmq']['policies']['ha-all']['pattern'] = '^(?!amq\\.).*'
default['rackspace_rabbitmq']['policies']['ha-all']['params'] = { 'ha-mode' => 'all' }
default['rackspace_rabbitmq']['policies']['ha-all']['priority'] = 0

default['rackspace_rabbitmq']['policies']['ha-two']['pattern'] = "^two\."
default['rackspace_rabbitmq']['policies']['ha-two']['params'] = { 'ha-mode' => 'exactly', 'ha-params' => 2 }
default['rackspace_rabbitmq']['policies']['ha-two']['priority'] = 1

default['rackspace_rabbitmq']['disabled_policies'] = []
