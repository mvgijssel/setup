variable "output_directory" {
  type = string
  default = "packer_output"
}

variable "setup_log_dir" {
  type = string
}

variable "ubuntu_image" {
  type = string
}

variable "ubuntu_checksum" {
  type = string
}

source "qemu" "libvirt" {
  vm_name = "libvirt.qcow2"
  iso_url           = var.ubuntu_image
  iso_checksum      = "file:${var.ubuntu_checksum}"

  output_directory  = var.output_directory
  shutdown_command  = "sudo shutdown -P now"
  format            = "qcow2"
  accelerator       = "hax"

  headless = true
  use_default_display = true
  display = "none"

  communicator = "ssh"
  ssh_username      = "ubuntu"
  ssh_private_key_file = "../secrets/id_rsa.development"

  disk_image = true
  use_backing_file = false

  net_device        = "virtio-net"
  disk_interface    = "virtio"

  # TODO: maybe special packer user-data/meta-data
  cd_files = ["./cloud-init/dev/user-data", "./cloud-init/dev/meta-data"]
  cd_label = "cidata"

  memory = 512

  qemuargs = [
    ["-serial", "file:${var.setup_log_dir}/libvirt.packer.log"],
  ]
}

build {
  sources = ["source.qemu.libvirt"]

  libvirt "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  libvirt "ansible" {
    playbook_file = "./playbook.yml"
    extra_arguments = [
      "--extra-vars", "architecture=amd64"
    ]
  }
}
