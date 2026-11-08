variable "libvirt_uri" {
  description = "Libvirt connection URI (e.g. qemu:///system or qemu+ssh://user@host/system)."
  type        = string
  default     = "qemu:///system"
}

variable "pool_name" {
  description = "Name of an existing libvirt storage pool used for volumes and cloud-init ISOs."
  type        = string
  default     = "default"
}

variable "name_prefix" {
  description = "Prefix applied to every libvirt object created by this stack."
  type        = string
  default     = "temper"
}

variable "base_image_source" {
  description = "URL or local path of a cloud-init enabled qcow2 image (Debian/Ubuntu)."
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "network_cidr" {
  description = "CIDR block of the isolated NAT network."
  type        = string
  default     = "10.10.10.0/24"
}

variable "network_domain" {
  description = "DNS domain served by the libvirt network."
  type        = string
  default     = "lab.local"
}

variable "admin_user" {
  description = "Admin user created by cloud-init and used by Ansible."
  type        = string
  default     = "ops"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into every node."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the matching private key, written into the generated Ansible inventory."
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "nodes" {
  description = "Map of node name to its specification. 'role' becomes the Ansible inventory group."
  type = map(object({
    role      = string
    vcpu      = optional(number, 1)
    memory_mb = optional(number, 1024)
    disk_gb   = optional(number, 10)
  }))
  default = {
    "web-01"  = { role = "web" }
    "web-02"  = { role = "web" }
    "util-01" = { role = "utility", memory_mb = 512 }
  }

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be defined."
  }
}

variable "generate_inventory" {
  description = "Write an Ansible inventory file from the created nodes."
  type        = bool
  default     = true
}
