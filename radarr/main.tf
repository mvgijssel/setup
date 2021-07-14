terraform {
  required_version = ">= 0.13.0"

  required_providers {
    kubernetes = {
      source  = "local/setup/kubernetes"
      version = "0.0.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_deployment" "radarr" {
  metadata {
    name = "radarr"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "radarr"
      }
    }

    template {
      metadata {
        labels = {
          app = "radarr"
        }
      }

      spec {
        container {
          name  = "radarr"
          image = "linuxserver/radarr"

          resources {
            limits {
              memory = "512Mi"
            }
            requests {
              memory = "512Mi"
            }
          }

          port {
            name           = "radarr-ui"
            container_port = 7878
            protocol       = "TCP"
          }

          env {
            name  = "PGID"
            value = 0
          }

          env {
            name  = "PUID"
            value = 0
          }

          env {
            name  = "TZ"
            value = "Europe/Amsterdam"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "radarr" {
  metadata {
    name = "radarr"
  }
  spec {
    selector = {
      app = "radarr"
    }
    port {
      name        = "radarr-ui"
      port        = 80
      target_port = "radarr-ui"
      protocol    = "TCP"
    }
  }
}

# TODO: Depends on the ingress controller!
resource "kubernetes_ingress" "radarr" {
  wait_for_load_balancer = true
  metadata {
    name = "radarr"
  }
  spec {
    rule {
      host = var.radarr_hostname
      http {
        path {
          path = "/"
          backend {
            service_name = "radarr"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = var.radarr_fqdn
      http {
        path {
          path = "/"
          backend {
            service_name = "radarr"
            service_port = 80
          }
        }
      }
    }
  }
}
