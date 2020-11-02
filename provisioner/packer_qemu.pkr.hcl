source "qemu" "provisioner" {
  iso_url           = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  iso_checksum      = "file:http://cloud-images.ubuntu.com/focal/current/SHA256SUMS"

  output_directory  = "the_output_directory"
  # shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  # disk_size         = "5000M"
  format            = "qcow2"
  accelerator       = "hax"

  # http_directory    = "path/to/httpdir"
  headless = true
  use_default_display = true
  display = "none"

  communicator = "ssh"
  ssh_username      = "ubuntu"
  ssh_private_key_file = "../secrets/id_rsa.development"

  disk_image = true
  use_backing_file = true

  net_device        = "virtio-net"
  disk_interface    = "virtio"

  cd_files = ["./cloud-init/user-data", "./cloud-init/meta-data"]
  cd_label = "cidata"

  memory = 1024

  qemuargs = [
    ["-serial", "file:packer.log"],
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

  provisioner "breakpoint" {
    disable = false
    note    = "this is a breakpoint"
  }
}