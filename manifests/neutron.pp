class controller_node::neutron( String $management_ip ){


  class { '::neutron':
    enabled         => true,
    bind_host       => '0.0.0.0',
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
    vni_ranges           => '1:1000',
    flat_networks => 'external'
  }

  vs_bridge{ 'br-int':
    ensure => present
  }~>

  # The bridge_uplinks setting will create port and set up ip of the bridge from the interface.
  # Therefore, it must be run after network_config is run.
  class { '::neutron::agents::ml2::ovs':
    subscribe => Class['::network_config'], 
    bridge_mappings => ['external:br-ext'],
    bridge_uplinks => ['br-ext:eno2'],
    enable_tunneling => true,
    tunnel_types => ['vxlan'],
    local_ip => $management_ip,
    l2_population => true,
    arp_responder => true,
    enable_distributed_routing => true  
  }

  # eno2.42 port is isolated here to prevent getting run in parallel with eno2 port
  # since when eno2 port is being configuring, eno2 will be restarted.
  # When eno2 is down and not get up yet, eno2.42 is down either.
  # Then the provider of vs_port will not copy ip form eno2.42 to br-int.
  neutron::plugins::ovs::port{ 'br-int:eno2.42':
    subscribe => Class['::network_config'],
    before => Vs_port['eno2'],
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
