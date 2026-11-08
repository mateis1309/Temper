variable "name_prefix" {
  description = "Prefix for all libvirt objects."
  type        = string
}

variable "pool_name" {
  description = "Existing libvirt storage pool."
  type        = string
}

variable "base_image_source" {
  description = "URL or path of the base cloud image."
  type        = string
}

variable "network_id" {
  description = "ID of the libvirt network nodes attach to."
  type        = string
}

variable "admin_user" {
  description = "Admin user created via cloud-init."
  type        = string
}

variable "ssh_public_key" {
  description = "Public key authorized for the admin user."
  type        = string
}

variable "nodes" {
  description = "Node specifications keyed by node name."
  type = map(object({
    role      = string
    vcpu      = optional(number, 1)
    memory_mb = optional(number, 1024)
    disk_gb   = optional(number, 10)
  }))
}
