output "nodes" {
  description = "Per-node details: role and first leased IPv4 address."
  value = {
    for name, n in var.nodes : name => {
      role = n.role
      ip   = try(libvirt_domain.node[name].network_interface[0].addresses[0], null)
    }
  }
}
