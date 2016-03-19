class controller_node::nova( String $management_ip ){

  class { 'nova':
    database_connection => "mysql://nova:${::password::nova_db}@127.0.0.1/nova",
    rabbit_userid       => 'openstack',
    rabbit_password     => $::password::rabbit,
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => 'localhost:9292',
    verbose             => true,
    rabbit_host         => '127.0.0.1',
  }

  # nova_config {
  #   'vnc/vncserver_listen': value => '0.0.0.0';
  #   'vnc/vncserver_proxyclient_address': value => $management_ip
  # } ~>
  
  class { 'nova::api':
    api_bind_address => $hostname,
    admin_password => $::password::nova
  }
  
  class { 'nova::keystone::auth':
    password         => $::password::nova,
    email            => "admin@${domain}",
    public_address   => "${hostname}",
    admin_address    => "${hostname}-admin",
    internal_address => "${hostname}-int",
    region           => 'RegionOne',
  }

  class { 'nova::db::mysql':
    password => $::password::nova_db,
    allowed_hosts => 'localhost'
  }

  include ::controller_node::rabbit_server
  class { 'nova::rabbitmq':
    require => Service['rabbitmq-server'],
    userid => 'openstack',
    password => $::password::rabbit
  }

  class{ 'nova::network::neutron':
    neutron_admin_password => $::password::neutron,    
    neutron_url => "http://127.0.0.1:9696",
    neutron_admin_auth_url => "http://127.0.0.1:35357/v2.0"
  }
  
  class { 'nova::cert':
  }

  class { 'nova::consoleauth':
  }

  class { 'nova::scheduler':
  }

  class { 'nova::conductor':
  }
  
  class { 'nova::vncproxy':
    # host => "${hostname}.cloud.csie.ntu.edu.tw"
  }

    
}
