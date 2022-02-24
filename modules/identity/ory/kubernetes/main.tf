resource "kubernetes_manifest" "oathkeeper_knative_service" {
  for_each = {
    proxy = {
      containerPort = try(var.config.serve.proxy.port, 4455)
    },
    api = {
      containerPort = try(var.config.serve.api.port, 4456)
    }
  }
  manifest = {
    apiVersion = "serving.knative.dev/v1"
    kind       = "Service"
    metadata = {
      labels      = var.labels
      annotations = var.annotations
      name        = "${var.name}-${each.key}"
      namespace   = var.namespace
    }
    spec = {
      template = {
        metadata = {
          labels = var.pod_labels
          annotations = merge(
            {
              "autoscaling.knative.dev/metric"    = var.metric,
              "autoscaling.knative.dev/target"    = var.target,
              "autoscaling.knative.dev/max-scale" = var.min_scale,
              "autoscaling.knative.dev/min-scale" = var.max_scale
            },
            var.pod_annotations
          )
        }
        spec = {
          containers = [
            {
              image = var.image
              name  = "oathkeeper"
              args = [
                "--config",
                "/etc/ory/oathkeeper/config.yaml",
                "serve"
              ]
              resources = var.resources
              ports = [
                {
                  name          = each.key
                  containerPort = each.value.containerPort
                }
              ]
              volumeMounts = [
                {
                  mountPath = "/etc/ory/oathkeeper"
                  name      = "config"
                  readOnly  = true
                },
              ]
            },
          ],
          volumes = [
            {
              name = "config"
              configMap = {
                name = kubernetes_manifest.oathkeeper_configmap.manifest.metadata.name
              }
            },
          ]
        },
      }
    }
  }
}

resource "kubernetes_manifest" "oathkeeper_configmap" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      labels = {
        app = var.name
      }
      name      = var.name
      namespace = var.namespace
    }
    immutable = true
    data = {
      "config.yaml" = yamlencode(var.config)
    }
  }
}
