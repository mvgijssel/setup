variable "kube_config_path" {
  type        = string
  description = "Path to Kubernetes config to use for kubectl."
}

variable "kubernetes_ingress_ip" {
  type        = string
  description = "ip address of the ingress-nginx service"
}

variable "kubernetes_metallb_ip_start" {
  type        = string
  description = "start of ip range metallb controls (https://metallb.universe.tf/configuration/)"
}

variable "kubernetes_metallb_ip_end" {
  type        = string
  description = "end of ip range metallb controls (https://metallb.universe.tf/configuration/)"

}
