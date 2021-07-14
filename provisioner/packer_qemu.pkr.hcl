variable "output_directory" {
  type = string
  default = "packer_output"
}

variable "setup_log_dir" {
  type = string
}

variable "setup_box_dir" {
  type = string
}

variable "ubuntu_image" {
  type = string
}

variable "ubuntu_checksum" {
  type = string
}

locals {
  provisioner_box_path = "${var.setup_box_dir}/provisioner.box"
}

source "qemu" "provisioner" {
  vm_name = "provisioner.qcow2"
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

  cd_files = ["./cloud-init/dev/user-data", "./cloud-init/dev/meta-data", "./cloud-init/dev/vendor-data"]
  cd_label = "cidata"

  memory = 512

  qemuargs = [
    ["-serial", "file:${var.setup_log_dir}/provisioner.packer.log"],
  ]
}

build {
  sources = ["source.qemu.provisioner"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    extra_arguments = [
      "--extra-vars", "architecture=amd64"
    ]
  }

  # provisioner "breakpoint" {
  #   disable = false
  #   note    = "this is a breakpoint"
  # }

  post-processors {
    post-processor "shell-local" {
      inline = ["cp -v ../scripts/qcow_to_vagrant/box.ovf ${var.output_directory}/box.ovf"]
    }

    post-processor "shell-local" {
      inline = ["qemu-img convert -f qcow2 -O vmdk ${var.output_directory}/provisioner.qcow2 ${var.output_directory}/box-disk001.vmdk"]
    }

    post-processor "artifice" {
      files = [
        "${var.output_directory}/box-disk001.vmdk",
        "${var.output_directory}/box.ovf",
      ]
    }

    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override = "virtualbox"
      output = local.provisioner_box_path
    }

    # Try to remove the locally box stored in Vagrant
    # so the next time "vagrant up" is run the new box is being used.
    post-processor "shell-local" {
      inline = ["vagrant box remove -f file://${local.provisioner_box_path}"]
      valid_exit_codes = [
        0,
        1,
      ]
    }
  }
}
