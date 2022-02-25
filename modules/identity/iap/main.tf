module "oathkeeper_serverless_service" {
  source = "../../../service"
  for_each = {
    proxy = {
      port = try(var.config.serve.proxy.port, 4455)
    },
    api = {
      port = try(var.config.serve.api.port, 4456)
    }
  }
  name        = "${var.name}-${each.key}"
  namespace   = var.namespace
  labels      = var.labels
  annotations = var.annotations
  image       = var.image
  args = [
    "--config",
    "/etc/ory/oathkeeper/config.json",
    "serve"
  ]
  cpu    = "500m"
  memory = "512Mi"
  port   = each.value.port
  volume_mounts = [
    {
      mountPath = "/etc/ory/oathkeeper"
      name      = "config"
      readOnly  = true
    },
  ]
  volumes = [
    {
      name = "config"
      configMap = {
        name = kubernetes_manifest.oathkeeper_configmap.manifest.metadata.name
      }
    },
  ]
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
    data = merge(
      { "config.json" = jsonencode(var.config) },
      {
        for k, v in var.access_rules :
        "${k}.json" => jsonencode(v)
      }
    )
  }
}
