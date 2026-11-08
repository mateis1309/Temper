variable "name" {
  description = "Libvirt network name."
  type        = string
}

variable "cidr" {
  description = "CIDR block for the network."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr, 1))
    error_message = "cidr must be a valid IPv4 CIDR block."
  }
}

variable "domain" {
  description = "DNS domain served by the network."
  type        = string
}

variable "mode" {
  description = "Libvirt network mode (nat, isolated, route)."
  type        = string
  default     = "nat"

  validation {
    condition     = contains(["nat", "isolated", "route"], var.mode)
    error_message = "mode must be one of: nat, isolated, route."
  }
}
