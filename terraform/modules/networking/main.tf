terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.1"
    }
  }
}

resource "libvirt_network" "this" {
  name      = var.name
  mode      = var.mode
  domain    = var.domain
  addresses = [var.cidr]
  autostart = true

  dns {
    enabled = true
  }
}
