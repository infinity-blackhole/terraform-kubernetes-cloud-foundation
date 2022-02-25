resource "kubernetes_manifest" "oathkeeper_knative_service" {
  manifest = {
    apiVersion = "serving.knative.dev/v1"
    kind       = "Service"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      template = merge(
        {
          for k, v in {
            metadata = merge(
              {
                for k, v in {
                  labels = var.labels
                } : k => v if v != null
              },
              {
                for k, v in {
                  annotations = merge(
                    {
                      for k, v in {
                        "autoscaling.knative.dev/metric"    = var.metric
                        "autoscaling.knative.dev/target"    = var.target
                        "autoscaling.knative.dev/max-scale" = var.min_instances
                        "autoscaling.knative.dev/min-scale" = var.max_instances
                      } : k => v if v != null
                    },
                    var.annotations
                  )
                } : k => v if length(v) > 0
              }
            ),
          } : k => v if length(v) > 0
        },
        {
          spec = merge(
            {
              for k, v in {
                containerConcurrency = var.concurrency
                timeoutSeconds       = var.timeout
                serviceAccountName   = var.service_account_name
                env                  = var.env
                volumes              = var.volumes
              } : k => v if v != null
            },
            {
              containers = [
                merge(
                  {
                    for k, v in {
                      image        = var.image
                      args         = var.args
                      command      = var.command
                      volumeMounts = var.volume_mounts
                    } : k => v if v != null
                  },
                  {
                    resources = {
                      limits = {
                        cpu    = var.cpu
                        memory = var.memory
                      }
                    }
                    ports = [
                      {
                        containerPort = var.port
                      }
                    ]
                  }
                )
              ]
            }
          )
        }
      )
    }
  }
}
