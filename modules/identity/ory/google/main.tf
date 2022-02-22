resource "google_cloud_run_service" "oathkeeper_proxy" {
  name                       = "${var.name}-proxy"
  location                   = var.location
  autogenerate_revision_name = true

  template {
    metadata {
      annotations = merge({
        "run.googleapis.com/sandbox"       = "gvisor",
        "client.knative.dev/user-image"    = var.image,
        "autoscaling.knative.dev/minScale" = var.min_scale,
        "autoscaling.knative.dev/maxScale" = var.max_scale,
        "run.googleapis.com/secrets"       = google_secret_manager_secret.oathkeeper_config.name
      }, var.annotations)
      labels    = var.labels
      namespace = var.namespace
    }
    spec {
      containers {
        image = var.image
        args = [
          "--config",
          "/secrets/config.yaml",
          "serve"
        ]
        ports = [
          {
            name          = "proxy"
            containerPort = try(var.config.serve.proxy.port, 4455)
          }
        ]
        resources = var.resources
        volume_mounts {
          name       = "config"
          mount_path = "/secrets"
        }
      }
      volumes {
        name = "config"
        secret {
          secret_name  = google_secret_manager_secret.oathkeeper_config.id
          default_mode = 292 # 0444
          items {
            key  = "1"
            path = "config.yaml"
            mode = 256 # 0400
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].spec[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_service" "oathkeeper_api" {
  name                       = "${var.name}-api"
  location                   = var.location
  autogenerate_revision_name = true

  template {
    metadata {
      annotations = merge({
        "run.googleapis.com/sandbox"       = "gvisor",
        "client.knative.dev/user-image"    = var.image,
        "autoscaling.knative.dev/minScale" = var.min_scale,
        "autoscaling.knative.dev/maxScale" = var.max_scale,
        "run.googleapis.com/secrets"       = google_secret_manager_secret.oathkeeper_config.name
      }, var.annotations)
      labels    = var.labels
      namespace = var.namespace
    }
    spec {
      containers {
        image = var.image
        args = [
          "--config",
          "/secrets/config.yaml",
          "serve"
        ]
        ports = [
          {
            name          = "api"
            containerPort = try(var.config.serve.proxy.port, 4456)
          }
        ]
        resources = var.resources
        volume_mounts {
          name       = "config"
          mount_path = "/secrets"
        }
      }
      volumes {
        name = "config"
        secret {
          secret_name  = google_secret_manager_secret.oathkeeper_config.id
          default_mode = 292 # 0444
          items {
            key  = "1"
            path = "config.yaml"
            mode = 256 # 0400
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].spec[0].containers[0].image
    ]
  }
}

resource "google_secret_manager_secret" "oathkeeper_config" {
  secret_id = var.name

  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "oathkeeper_config_default" {
  secret      = google_secret_manager_secret.oathkeeper_config.id
  secret_data = " "
}
