module "oathkeeper_serverless_service" {
  source = "../../../service/google"
  for_each = {
    proxy = {
      port = try(var.config.serve.proxy.port, 4455)
    },
    api = {
      port = try(var.config.serve.api.port, 4456)
    }
  }
  region      = var.region
  name        = "${var.name}-${each.key}"
  namespace   = var.namespace
  labels      = var.labels
  annotations = var.annotations
  image       = var.image
  args = [
    "--config",
    "/etc/ory/oathkeeper/config.yaml",
    "serve"
  ]
  cpu    = "500m"
  memory = "512Mi"
  port   = each.value.port
  volume_mounts = [
    {
      mountPath = "/etc/ory/oathkeeper"
      name      = "config"
    },
  ]
  volumes = [
    {
      name = "config"
      gcpSecret = {
        name        = google_secret_manager_secret.oathkeeper_config.id
        defaultMode = 292 # 0444
        items = [
          {
            key  = "1"
            path = "config.yaml"
            mode = 256 # 0400
          }
        ]
      }
    }
  ]
}

resource "google_secret_manager_secret" "oathkeeper_config" {
  secret_id = var.name

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "oathkeeper_config_default" {
  secret      = google_secret_manager_secret.oathkeeper_config.id
  secret_data = " "
}
