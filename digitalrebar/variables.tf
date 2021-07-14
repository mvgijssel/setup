variable "provisioner_fqdn" {
  type        = string
  description = "Fully Qualified Domain Name of the provisioner"
}

variable "digital_rebar_image" {
  type        = string
  description = "Name of the digital rebar docker image"
}

variable "docker_registry" {
  type        = string
  description = "Docker registry used to pull images"
}
