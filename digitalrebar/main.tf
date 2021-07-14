provider "docker" {
  host = "ssh://${var.provisioner_fqdn}"
}

resource "docker_container" "digitalrebar" {
  image        = docker_image.digitalrebar.latest
  name         = "digitalrebar"
  restart      = "always"
  start        = "true"
  network_mode = "host"

  volumes {
    volume_name    = docker_volume.digitalrebar.name
    container_path = "/provision/drp-data"
  }

  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml -i ${var.provisioner_fqdn},"
  }
}

data "external" "docker_build_info" {
  program = ["docker_build_info.sh"]
}

data "docker_registry_image" "digitalrebar" {
  name = "${var.docker_registry}/${var.digital_rebar_image}:${data.external.docker_build_info.result.ref}"
}

resource "docker_image" "digitalrebar" {
  name          = data.docker_registry_image.digitalrebar.name
  pull_triggers = [data.docker_registry_image.digitalrebar.sha256_digest]
}

resource "docker_volume" "digitalrebar" {
  name = "digitalrebar"
}
