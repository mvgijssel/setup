terraform {
  required_version = ">= 0.13.0"

  required_providers {
    # TODO: https://github.com/dmacvicar/terraform-provider-libvirt/issues/747
    libvirt = {
      source = "local/setup/libvirt"
      version = "0.0.1"
    }
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud-init/user-data.yml")
  vars = {
    public_key = file(var.public_key_path)
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/cloud-init/network-config.yml")
}

resource "libvirt_volume" "node" {
  name   = "${var.name}.qcow2"
  pool   = var.libvirt_pool_name
  source = var.image_path
}

resource "libvirt_cloudinit_disk" "node" {
  name           = "${var.name}.cloudinit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  meta_data      = "local-hostname: ${var.name}"
  pool           = var.libvirt_pool_name
}

resource "libvirt_domain" "node" {
  name       = var.name
  memory     = var.memory
  vcpu       = var.cpu_count
  qemu_agent = true
  autostart  = true

  disk {
    volume_id = libvirt_volume.node.id
  }

  cloudinit = libvirt_cloudinit_disk.node.id

  network_interface {
    wait_for_lease = true
    bridge         = var.network_bridge
    hostname = var.name
  }

  console {
    type        = "pty"
    target_port = "0"
    # target_type = "serial"
    # source_path = "/data/vms/logs/master.log"
  }
}
