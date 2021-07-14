variable "kube_config_path" {
  type        = string
  description = "Path for Kubernetes config to use for kubectl."
}

variable "radarr_fqdn" {
  type        = string
  description = "Fully Qualified Domain Name for the radarr service"
}

variable "radarr_hostname" {
  type        = string
  description = "hostname for the radarr service"
}
