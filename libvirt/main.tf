provider "drp" {
  username = "rocketskates"
  password = "r0cketsk8ts"
}

# TODO: how to recover machines in building state in resource pool?
# TODO: failed machine does not show up as failing in terraform

# TODO: convert image to using packer! Same as provisioner image
# TODO: instead of uploading run a file server.
# normally production will use github releases as well

data "external" "image_info" {
  program = ["image_info.sh", "${path.module}/image.cfg"]
}

locals {
  libvirt_image        = "../${data.external.image_info.result.relative_path_tgz}"
  remote_libvirt_image = "images/libvirt.tgz"
}

resource "null_resource" "upload_image" {
  triggers = {
    image_sha = local.libvirt_image
  }

  provisioner "local-exec" {
    command = "drpcli files upload ${local.libvirt_image} as ${local.remote_libvirt_image}"
  }
}

resource "drp_machine" "libvirt" {
  pool = "base"
  add_parameters = [
    "image-deploy/image-file: files/${local.remote_libvirt_image}",
    "image-deploy/image-sha: ${null_resource.upload_image.triggers.image_sha}",
  ]
  timeout = "3m"
}
