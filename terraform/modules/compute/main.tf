terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.1"
    }
  }
}

# One shared base image; every node gets a copy-on-write overlay of it.
resource "libvirt_volume" "base" {
  name   = "${var.name_prefix}-base.qcow2"
  pool   = var.pool_name
  source = var.base_image_source
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  for_each = var.nodes

  name           = "${var.name_prefix}-${each.key}.qcow2"
  pool           = var.pool_name
  base_volume_id = libvirt_volume.base.id
  size           = each.value.disk_gb * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "init" {
  for_each = var.nodes

  name = "${var.name_prefix}-${each.key}-init.iso"
  pool = var.pool_name
  user_data = templatefile("${path.module}/templates/user_data.yaml.tftpl", {
    hostname       = each.key
    admin_user     = var.admin_user
    ssh_public_key = var.ssh_public_key
  })
}

resource "libvirt_domain" "node" {
  for_each = var.nodes

  name      = "${var.name_prefix}-${each.key}"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu
  cloudinit = libvirt_cloudinit_disk.init[each.key].id

  network_interface {
    network_id     = var.network_id
    hostname       = each.key
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.disk[each.key].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
