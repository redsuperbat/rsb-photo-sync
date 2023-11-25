terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "kubernetes" {
    namespace     = "terraform-backend"
    secret_suffix = "rsb-photo-sync"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  namespace = "rsb-apps"
  name      = "rsb-photo-sync"
}

variable "image_tag" {
  type = string
}
variable "ftp_uri" {
  type = string
}


data "terraform_remote_state" "rsb_photoprism" {
  backend = "kubernetes"
  config = {
    namespace     = "terraform-backend"
    secret_suffix = "rsb-photoprism"
    config_path   = "~/.kube/config"
  }
}



resource "kubernetes_cron_job_v1" "nordic_wellness_booker_job" {
  metadata {
    name      = local.name
    namespace = local.namespace
  }


  spec {
    // “At 04:03 on every day-of-month.”
    schedule = "3 4 */1 * *"
    job_template {
      metadata {
        name = local.name
      }
      spec {
        template {
          metadata {
            labels = {
              app = local.name
            }
          }
          spec {
            container {
              name  = local.name
              image = "maxrsb/rsb-photo-sync:${var.image_tag}"
              volume_mount {
                name       = local.name
                mount_path = "/app/photos"
              }
              env {
                name  = "FTP_URI"
                value = var.ftp_uri
              }
              resources {
                requests = {
                  cpu    = "20m"
                  memory = "50Mi"
                }

                limits = {
                  cpu    = "200m"
                  memory = "200Mi"
                }
              }
            }

            volume {
              name = local.name
              persistent_volume_claim {
                claim_name = data.terraform_remote_state.rsb_photoprism.outputs.pvc_name
                read_only  = true
              }
            }
          }
        }
      }
    }
  }
}
