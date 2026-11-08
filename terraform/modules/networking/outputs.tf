output "network_id" {
  description = "ID of the libvirt network."
  value       = libvirt_network.this.id
}

output "cidr" {
  description = "CIDR block of the network."
  value       = var.cidr
}
