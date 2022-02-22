resource "kubernetes_manifest" "oathkeeper_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      labels      = var.labels
      annotations = var.annotations
      name        = var.name
      namespace   = var.namespace
    }
    spec = {
      replicas = var.replicas
      selector = {
        matchLabels = var.pod_labels
      }
      template = {
        metadata = {
          labels      = var.pod_labels
          annotations = var.pod_annotations
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
                  name          = "proxy"
                  containerPort = try(var.config.serve.proxy.port, 4455)
                },
                {
                  name          = "api"
                  containerPort = try(var.config.serve.api.port, 4456)
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
