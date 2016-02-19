class controller_node::nova {
  class { 'nova':
    database_connection => "mysql://nova:${::password::nova_db}@127.0.0.1/nova",
    rabbit_userid       => 'openstack',
    rabbit_password     => $::password::rabbit,
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => 'localhost:9292',
    verbose             => true,
    rabbit_host         => '127.0.0.1',
  }

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

  
  class { 'nova::cert':
  }

  class { 'nova::consoleauth':
  }

  class { 'nova::scheduler':
  }

  class { 'nova::conductor':
  }
  
  class { 'nova::vncproxy':
    host => "${hostname}-int"
  }
  
}
