name 'rackspace_rabbitmq'
maintainer 'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
description 'Installs and configures rabbitmq'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

recipe 'rackspace_rabbitmq', 'Install and configure RabbitMQ'
recipe 'rackspace_rabbitmq::cluster', 'Set up RabbitMQ clustering.'
recipe 'rackspace_rabbitmq::plugin_management', 'Manage plugins with node attributes'
recipe 'rackspace_rabbitmq::virtualhost_management', 'Manage virtualhost with node attributes'
recipe 'rackspace_rabbitmq::user_management', 'Manage users with node attributes'
depends 'erlang', '>= 0.9'

%w(ubuntu debian redhat centos).each do |os|
  supports os
end

attribute 'rackspace_rabbitmq',
          display_name: 'RabbitMQ',
          description: 'Hash of RabbitMQ attributes',
          type: 'hash'

attribute 'rackspace_rabbitmq/nodename',
          display_name: 'RabbitMQ Erlang node name',
          description: 'The Erlang node name for this server.',
          default: "node['hostname']"

attribute 'rackspace_rabbitmq/address',
          display_name: 'RabbitMQ server IP address',
          description: 'IP address to bind.'

attribute 'rackspace_rabbitmq/port',
          display_name: 'RabbitMQ server port',
          description: 'TCP port to bind.'

attribute 'rackspace_rabbitmq/config',
          display_name: 'RabbitMQ config file to load',
          description: 'Path to the rabbitmq.config file, if any.'

attribute 'rackspace_rabbitmq/logdir',
          display_name: 'RabbitMQ log directory',
          description: 'Path to the directory for log files.'

attribute 'rackspace_rabbitmq/mnesiadir',
          display_name: 'RabbitMQ Mnesia database directory',
          description: 'Path to the directory for Mnesia database files.'

attribute 'rackspace_rabbitmq/cluster',
          display_name: 'RabbitMQ clustering',
          description: 'Whether to activate clustering.',
          default: 'no'

attribute 'rackspace_rabbitmq/cluster_config',
          display_name: 'RabbitMQ clustering configuration file',
          description: 'Path to the clustering configuration file, if cluster is yes.',
          default: '/etc/rabbitmq/rabbitmq_cluster.config'

attribute 'rackspace_rabbitmq/cluster_disk_nodes',
          display_name: 'RabbitMQ cluster disk nodes',
          description: 'Array of member Erlang nodenames for the disk-based storage nodes in the cluster.',
          default: [],
          type: 'array'

attribute 'rackspace_rabbitmq/erlang_cookie',
          display_name: 'RabbitMQ Erlang cookie',
          description: 'Access cookie for clustering nodes.  There is no default.'

attribute 'rackspace_rabbitmq/virtualhosts',
          display_name: 'Virtualhosts on rabbitmq instance',
          description: 'List all virtualhosts that will exist',
          default: [],
          type: 'array'

attribute 'rackspace_rabbitmq/enabled_users',
          display_name: 'Users and their rights on rabbitmq instance',
          description: 'Users and description of their rights',
          default: [{ name: 'guest', password: 'guest', rights: [{ vhost: nil , conf: '.*', write: '.*', read: '.*' }] }],
          type: 'array'

attribute 'rackspace_rabbitmq/disabled_users',
          display_name: 'Disabled users',
          description: 'List all users that will be deactivated',
          default: [],
          type: 'array'

attribute 'rackspace_rabbitmq/enabled_plugins',
          display_name: 'Enabled plugins',
          description: 'List all plugins that will be activated',
          default: [],
          type: 'array'

attribute 'rackspace_rabbitmq/disabled_plugins',
          display_name: 'Disabled plugins',
          description: 'List all plugins that will be deactivated',
          default: [],
          type: 'array'

attribute 'rackspace_rabbitmq/local_erl_networking',
          display_name: 'Local Erlang networking',
          description: 'Bind erlang networking to localhost'

attribute 'rackspace_rabbitmq/erl_networking_bind_address',
          display_name: 'Erl Networking Bind Address',
          description: 'Bind Rabbit and erlang networking to an address'
