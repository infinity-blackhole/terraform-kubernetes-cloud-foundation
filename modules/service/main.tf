resource "kubernetes_manifest" "service" {
  manifest = {
    apiVersion = "serving.knative.dev/v1"
    kind       = "Service"
    metadata   = var.metadata
    spec = merge(
      try(var.spec, {}),
      {
        template = merge(
          try(var.spec.template, {}),
          {
            metadata = merge(
              try(var.spec.template.metadata, {}),
              {
                annotations = merge(
                  {
                    "autoscaling.knative.dev/metric"    = var.metric,
                    "autoscaling.knative.dev/target"    = var.target,
                    "autoscaling.knative.dev/min-scale" = var.min_scale,
                    "autoscaling.knative.dev/max-scale" = var.max_scale
                  },
                  var.pod_annotations
                )
              }
            )
          }
        )
      }
    )
  }
}
