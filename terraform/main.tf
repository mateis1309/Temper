locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  # { role => [ { name, ip }, ... ] } used to render inventory groups.
  inventory_groups = {
    for role in distinct([for n in var.nodes : n.role]) : role => [
      for name, n in var.nodes : {
        name = name
        ip   = module.compute.nodes[name].ip
      } if n.role == role
    ]
  }
}

module "networking" {
  source = "./modules/networking"

  name   = "${var.name_prefix}-net"
  cidr   = var.network_cidr
  domain = var.network_domain
}

module "compute" {
  source = "./modules/compute"

  name_prefix       = var.name_prefix
  pool_name         = var.pool_name
  base_image_source = var.base_image_source
  network_id        = module.networking.network_id
  admin_user        = var.admin_user
  ssh_public_key    = local.ssh_public_key
  nodes             = var.nodes
}

resource "local_file" "ansible_inventory" {
  count = var.generate_inventory ? 1 : 0

  lifecycle {
    precondition {
      condition     = alltrue([for n in module.compute.nodes : n.ip != null])
      error_message = "Some nodes have no IPv4 lease yet. Wait for DHCP and re-run 'make up' (terraform apply)."
    }
  }

  filename             = "${path.root}/../ansible/inventory/hosts.ini"
  file_permission      = "0600"
  directory_permission = "0755"
  content = templatefile("${path.root}/templates/inventory.ini.tftpl", {
    groups               = local.inventory_groups
    admin_user           = var.admin_user
    ssh_private_key_path = pathexpand(var.ssh_private_key_path)
  })
}
