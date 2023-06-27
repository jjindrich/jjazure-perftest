locals {
    image_tag = "perftest:v3"
}

provider "kubernetes" {
    host                   = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate)
}

resource "null_resource" "build_perftest_image" {
  provisioner "local-exec" {
    command = "az acr build -t ${local.image_tag} -r ${var.acr_name} ${abspath(format("%s/../perftest", path.module))} -f ${abspath(format("%s/../perftest/DockerfileTf", path.module))} --platform linux"
  }

  depends_on = [
    azurerm_container_registry.acr
  ]
}

resource "kubernetes_namespace" "perftest" {
  metadata {
    name = "perftest"
  }

  depends_on = [
    null_resource.build_perftest_image
  ]
}

# ACR default system scope maps
data "azurerm_container_registry_scope_map" "pull" {
  name                    = "_repositories_pull"
  resource_group_name     = azurerm_resource_group.rsg-app.name
  container_registry_name = azurerm_container_registry.acr.name
}

resource "azurerm_container_registry_token" "aks" {
  name                    = "aks-pull"
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = azurerm_resource_group.rsg-app.name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull.id
}

resource "azurerm_container_registry_token_password" "aks" {
  container_registry_token_id = azurerm_container_registry_token.aks.id

  password1 {
  }
}


# database
resource "azurerm_mysql_flexible_server" "perftest" {
  name                   = "${var.mysql_name_prefix}-perftest"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rsg-data-db.name
  administrator_login    = "azureadmin"
  administrator_password = random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = 20
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "perftest" {
  name                = "perftest"
  resource_group_name = azurerm_resource_group.rsg-data-db.name
  server_name         = azurerm_mysql_flexible_server.perftest.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

# Pull secret needed for virtual nodes as we can't use managed identity on those
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
