class controller_node::neutron{


  class { '::neutron':
    enabled         => true,
    bind_host       => $hostname,
    rabbit_host     => '127.0.0.1',
    rabbit_user     => 'openstack',
    rabbit_password => $::password::rabbit,
    verbose         => true,
    debug           => false,
    core_plugin => 'ml2',
    service_plugins => ['router'],
    allow_overlapping_ips => true,
    lock_path => '/var/lib/neutron/tmp'
  }


  class { 'neutron::server::notifications':
    password => $::password::nova,
    region_name => 'RegionOne'
  }  

  class { 'neutron::keystone::auth':
    password => $::password::neutron,
    # urls are using localhost as defult
  }


  class { 'neutron::db::mysql':
    password => $::password::neutron_db,
    allowed_hosts => 'localhost'
  }
  
  # configure authentication
  class { 'neutron::server':
    auth_host       => '127.0.0.1', # the keystone host address
    auth_password   => $::password::neutron,
    database_connection  => "mysql://neutron:${::password::neutron_db}@127.0.0.1/neutron",
    sync_db => true
  }

  # ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan', 'flat', 'vlan'],
    tenant_network_types => ['vxlan'],
    vxlan_group          => '239.1.1.1',
    mechanism_drivers    => ['openvswitch', 'l2population'],
    vni_ranges           => '1:1000'
  }


  class { '::neutron::agents::ml2::ovs':
    bridge_mappings => ['external:br-ext'],
    enable_tunneling => true,
    tunnel_types => ['vxlan'],
    local_ip => "${hostname}-int",
    l2_population => true,
    arp_responder => true,
    enable_distributed_routing => true  
  }

  class { '::neutron::agents::l3':
    use_namespaces => true,
    external_network_bridge => '',
    router_delete_namespaces => true,
    agent_mode => 'dvr_snat'
  }

  class { '::neutron::agents::metadata':
    metadata_ip => '127.0.0.1',
    auth_password => $::password::neutron,
    shared_secret => $::password::neutron_meta_proxy,
    auth_region => 'RegionOne'
  }

  class { '::neutron::agents::dhcp':
    use_namespaces => true,
    dhcp_delete_namespaces => true,
  }

}
