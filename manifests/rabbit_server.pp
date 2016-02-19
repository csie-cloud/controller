class controller_node::rabbit_server {

  package{'rabbitmq-server':
    ensure => 'installed'
  } 

  service{ 'rabbitmq-server':
    ensure => 'running',
  } 

  Package['rabbitmq-server'] -> Service['rabbitmq-server']

}
