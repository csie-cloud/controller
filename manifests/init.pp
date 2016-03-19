class controller_node( String $management_ip) {
  include ::controller_node::keystone
  include ::controller_node::glance
  include ::controller_node::horizon

  class{ '::controller_node::nova':
    management_ip => $management_ip
  }
  
  class{ '::controller_node::neutron':
    management_ip => $management_ip
  }
}
