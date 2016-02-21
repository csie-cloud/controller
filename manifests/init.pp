class controller_node( String $ovs_external_ip) {
  include ::controller_node::keystone
  include ::controller_node::glance
  include ::controller_node::nova
  include ::controller_node::horizon
  
  class{ '::controller_node::neutron':
    external_ip => $ovs_external_ip
  }
}
