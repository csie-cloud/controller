class controller_node::keystone{
  # Keystone
  include ::password
  Exec { logoutput => 'on_failure' }

  class { '::mysql::server': }
  
  class { '::keystone::db::mysql':
    password => $::password::keystone_db,
    allowed_hosts => 'localhost'
  }
  
  package{'centos-release-openstack-liberty':
    ensure => present
  }
  
  class { '::keystone':
    verbose             => true,
    debug               => true,
    database_connection => "mysql://keystone:${::password::keystone_db}@localhost/keystone",
    admin_token         => $::password::keystone_token,
    catalog_type        => 'sql',
    enabled             => false, # service openstack-keystone should never be started.
    service_name => "httpd",
    require => Package['centos-release-openstack-liberty']
  }
  
  class { '::keystone::roles::admin':
    email => 'admin@cloud.csie.ntu.edu.tw',
    password            => $::password::user_admin,
  }
  
  class { '::keystone::endpoint':
    public_url => "http://${hostname}:5000",
    admin_url  => "http://${hostname}-admin:35357",
    internal_url => "http://${hostname}-int:5000",
    region => 'RegionOne'
  }


  include ::apache

  class { '::keystone::wsgi::apache':
    ssl         => false,
    public_port => 5000,
    admin_port  => 35357,
  }
  
  keystone_tenant { 'service':
    ensure => present
  }

  keystone_tenant { 'admin':
    ensure => present
  }
  
  keystone_user_role { 'admin::default@admin::default':
    ensure => present,
    roles  => ['admin']
  }  

  keystone_tenant { 'demo':
    ensure => present,
  }

  
  keystone_user { 'demo':
    ensure => present,
    enabled => true,
    password => $::password::user_demo
  }

  keystone_role { 'user':
    ensure => present,
  }
  
  keystone_user_role { 'admin::default@demo::default':
    ensure => present,
    roles  => ['user']
  }  

}
