resource "google_cloud_run_service" "cloudrun_runner" {
  name                       = var.name
  location                   = var.region
  autogenerate_revision_name = true

  metadata {
    namespace = var.namespace
  }

  template {
    metadata {
      labels = var.labels
      annotations = merge(
        {
          "run.googleapis.com/sandbox"       = var.sandbox,
          "autoscaling.knative.dev/minScale" = var.min_instances,
          "autoscaling.knative.dev/maxScale" = var.max_instances
        },
        var.annotations
      )
    }
    spec {
      container_concurrency = var.concurrency
      timeout_seconds       = var.timeout
      service_account_name  = var.service_account_name
      containers {
        image   = var.image
        args    = var.args
        command = var.command
        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }
        ports {
          name           = var.protocol_version
          container_port = var.port
        }
        dynamic "env" {
          for_each = coalesce(var.env, [])
          content {
            name  = env.name
            value = coalesce(env.value, null)
            value_from {
              secret_key_ref {
                key  = coalesce(env.valueFrom.gcpSecretKeyRef.key, null)
                name = coalesce(env.valueFrom.gcpSecretKeyRef.name, null)
              }
            }
          }
        }
        dynamic "volume_mounts" {
          for_each = var.volume_mounts
          content {
            name       = volume_mounts.key
            mount_path = volume_mounts.value.mountPath
          }
        }
      }
      dynamic "volumes" {
        for_each = var.volumes
        content {
          name = volumes.key
          secret {
            secret_name  = volumes.value.gcpSecret.name
            default_mode = volumes.value.gcpSecret.defaultMode
            dynamic "items" {
              for_each = coalesce(volumes.value.gcpSecret.items, [])
              content {
                key  = items.value.key
                path = items.value.path
                mode = items.value.mode
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["run.googleapis.com/user-image"],
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].spec[0].containers[0].image,
    ]
  }
}
