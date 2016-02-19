class controller_node {
  include ::controller_node::keystone
  include ::controller_node::glance
  include ::controller_node::nova
  include ::controller_node::neutron
}
