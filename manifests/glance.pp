class controller_node::glance{
  $_database_url = "mysql://glance:${::password::glance_db}@127.0.0.1/glance"
  
  notify{ 'tmp':
    message => "*** password: ${::password::glance} *** "
  }
  
  class { 'glance::api':
    verbose             => true,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    keystone_password   => $::password::glance,
    database_connection => $_database_url,
  }

  class { 'glance::registry':
    verbose             => true,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    keystone_password   => $::password::glance,
    database_connection => $_database_url,
  }

  class { 'glance::backend::file': }

  class { 'glance::db::mysql':
    password      => $::password::glance_db,
    allowed_hosts => 'localhost',
  }

  class { 'glance::keystone::auth':
    password         => $::password::glance,
    email            => "admin@${domain}",
    public_address   => "${hostname}",
    admin_address    => "${hostname}-admin",
    internal_address => "${hostname}-int",
    region           => 'RegionOne',
  }

}
