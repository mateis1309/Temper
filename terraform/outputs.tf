output "nodes" {
  description = "Created nodes with role and IP address."
  value       = module.compute.nodes
}

output "network_cidr" {
  description = "CIDR of the libvirt network."
  value       = module.networking.cidr
}

output "inventory_path" {
  description = "Path of the generated Ansible inventory (null if disabled)."
  value       = var.generate_inventory ? abspath(local_file.ansible_inventory[0].filename) : null
}
