terraform {
  required_version = ">= 0.13.0"

  required_providers {
    # TODO: https://github.com/dmacvicar/terraform-provider-libvirt/issues/747
    libvirt = {
      source  = "local/setup/libvirt"
      version = "0.0.1"
    }
  }
}

data "external" "image_info" {
  program = ["image_info.sh", "${path.module}/image.cfg"]
}

locals {
  kubernetes_image = "../${data.external.image_info.result.relative_path_qcow}"
}

provider "libvirt" {
  uri = "qemu+ssh://${var.libvirt_fqdn}/system?socket=/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "data" {
  name = var.libvirt_pool_name
  type = "dir"
  path = "${var.libvirt_vm_dir}/${var.libvirt_pool_name}"
}

resource "libvirt_network" "kube_network" {
  name      = var.network_bridge
  mode      = "bridge"
  bridge    = var.network_bridge
  autostart = true
}

module "master" {
  source = "./modules/node"

  name              = "${var.master_hostname}.${var.parent_domain}"
  public_key_path   = var.public_key_path
  image_path        = local.kubernetes_image
  libvirt_pool_name = libvirt_pool.data.name
  network_bridge    = libvirt_network.kube_network.bridge
  memory            = var.worker_memory
  cpu_count         = var.worker_cpu_count
}

resource "null_resource" "master" {
  triggers = {
    master_id = module.master.id
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/kubeadm_init.sh ${module.master.fqdn}"
  }
}

module "worker" {
  source = "./modules/node"

  count             = var.worker_count
  name              = "${var.worker_hostname}${count.index}.${var.parent_domain}"
  public_key_path   = var.public_key_path
  image_path        = local.kubernetes_image
  libvirt_pool_name = var.libvirt_pool_name
  network_bridge    = var.network_bridge
  memory            = var.worker_memory
  cpu_count         = var.worker_cpu_count
}

resource "null_resource" "worker" {
  count = var.worker_count

  # Only start worker provisioning when the master is ready
  depends_on = [
    null_resource.master,
  ]

  triggers = {
    worker_id = module.worker[count.index].id
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/kubeadm_join.sh ${module.master.fqdn} ${module.worker[count.index].fqdn}"
  }
}
