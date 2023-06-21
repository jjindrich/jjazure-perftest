resource "kubernetes_namespace" "perftest" {
  metadata {
    name = "perftest"
  }
}

// needed by virtual nodes isntead of managed identity
resource "kubernetes_secret" "regcred" {
  metadata {
    name      = "regcred"
    namespace = kubernetes_namespace.perftest.metadata.0.name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          "username" = azurerm_container_registry_token.aks.name
          "password" = azurerm_container_registry_token_password.aks.password1[0].value
          "email"    = "test@test.cz"
          "auth"     = base64encode("${azurerm_container_registry_token.aks.name}:${azurerm_container_registry_token_password.aks.password1[0].value}")
        }
      }
    })
  }
}

resource "kubernetes_deployment" "perftest" {
  metadata {
    name      = "perftest"
    namespace = kubernetes_namespace.perftest.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "perftest"
      }
    }

    template {
      metadata {
        labels = {
          app = "perftest"
        }
      }

      spec {
        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "agentpool"
                  operator = "In"
                  values   = ["nodepool1"]
                }
              }
            }
          }
        }

        image_pull_secrets {
          name = kubernetes_secret.regcred.metadata[0].name
        }

        container {
          name              = "perftest"
          image             = "${azurerm_container_registry.acr.login_server}/${local.image_tag}"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }

          env {
            name  = "ConnectionStrings__MySqlDatabase"
            value = "server=${azurerm_mysql_flexible_server.perftest.fqdn}; database=${azurerm_mysql_flexible_database.perftest.name}; user=${azurerm_mysql_flexible_server.perftest.administrator_login}; password=${random_password.mysql_root_password.result}"
          }

          resources {
            requests = {
              "cpu"  = "1"
              memory = "1G"
            }
            limits = {
              "cpu"    = "1"
              "memory" = "1G"
            }
          }
        }

        toleration {
          key      = "virtual-kubelet.io/provider"
          operator = "Exists"
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"
        }
      }
    }
  }
}

resource "kubernetes_service" "perftest" {
  metadata {
    name      = "perftest-service"
    namespace = kubernetes_namespace.perftest.metadata.0.name

    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      app = kubernetes_deployment.perftest.spec[0].template[0].metadata[0].labels.app
    }

    type = "LoadBalancer"
  }
}

locals {
  perftest_lb_ip = kubernetes_service.perftest.status[0].load_balancer[0].ingress[0].ip
}
