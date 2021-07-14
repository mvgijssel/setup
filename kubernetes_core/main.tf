terraform {
  required_version = ">= 0.13.0"

  required_providers {
    helm = {
      source  = "local/setup/helm"
      version = "0.0.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  version    = "0.1.21"

  set {
    name  = "configInline"
    value = <<EOT
address-pools:
- name: default
  protocol: layer2
  addresses:
  - ${var.kubernetes_metallb_ip_start}-${var.kubernetes_metallb_ip_end}
    EOT
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx/"
  chart      = "ingress-nginx"
  version    = "2.12.1"

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.kubernetes_ingress_ip
  }
}
