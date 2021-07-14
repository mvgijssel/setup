locals {
  image_mount_path = "/tmp/packer_mount_dir"
}

variable "base_image_absolute_path" {
  type = string
}

variable "output_image" {
  type = string
}

# variable "setup_provisioner_dir" {
#   type = string
# }

source "arm" "provisioner" {
  # Use local file url: https://github.com/mkaczanowski/packer-builder-arm/issues/8
  file_urls = [
    "file://${var.base_image_absolute_path}"
  ]
  # file_checksum_url = "http://cdimage.ubuntu.com/releases/20.04.1/release/SHA256SUMS"
  file_checksum_type = "none"
  file_target_extension = "xz"
  file_unarchive_cmd = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method = "reuse"
  image_path = var.output_image
  image_size = "3.1G"
  image_mount_path = local.image_mount_path
  image_type = "dos"

  image_partitions {
    name = "boot"
    type = "c"
    start_sector = 2048
    filesystem = "fat"
    size = "256M"
    mountpoint = "/boot/firmware"
  }

  image_partitions {
    name = "root"
    type = "83"
    start_sector = 526336
    filesystem = "ext4"
    size = "2.8G"
    mountpoint = "/"
  }

  image_chroot_env = [
    "PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
  ]

  qemu_binary_source_path = "/usr/bin/qemu-aarch64-static"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.arm.provisioner"]

  # provisioner "breakpoint" {
  #   disable = false
  #   note    = "this is a breakpoint"
  # }

  # we have to replace the existing resolv.conf because it relies on systemd-resolved
  # which is not running when we chroot into the image.
  provisioner "shell" {
    inline = [
      "mv -v /etc/resolv.conf /etc/resolv.conf.orig",
      "echo 'nameserver 8.8.8.8' > /etc/resolv.conf",
    ]
  }

  # provisioner "ansible" {
  #   playbook_file = "${var.setup_provisioner_dir}/playbook.yml"
  #   # NOTE: the trailing comma is really important in "inventory_file" otherwise all the files
  #   # and folders in the directory will be used as inventory hosts as described here
  #   # https://www.reddit.com/r/ansible/comments/8kc59a/how_to_use_the_chroot_connection_plugin/dz7nq3c/
  #   inventory_file = "${local.image_mount_path},"
  #   extra_arguments = [
  #     "--connection=chroot",
  #     "--extra-vars=architecture=arm64",
  #   ]
  # }

  # Restore the temporary resolv.conf with the one from systemd-resolved
  provisioner "shell" {
    inline = [
      "rm -v /etc/resolv.conf",
      "mv -v /etc/resolv.conf.orig /etc/resolv.conf",
    ]
  }
}
