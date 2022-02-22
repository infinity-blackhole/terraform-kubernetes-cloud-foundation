variable "name" {
  type    = string
  default = "oathkeeper"
}

variable "location" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "labels" {
  type = map(string)
  default = {
    "run.googleapis.com/sandbox" = "gvisor"
  }
}

variable "annotations" {
  type    = map(string)
  default = null
}

variable "replicas" {
  type    = number
  default = 1
}

variable "min_scale" {
  type    = number
  default = 0
}

variable "max_scale" {
  type    = number
  default = 3
}

variable "image" {
  type    = string
  default = "docker.io/oryd/oathkeeper:latest"
}

variable "config" {
  type = any
  default = {
    serve = {
      proxy = {
        port = 4456
      },
      api = {
        port = 4455
      }
    }
  }
}

variable "resources" {
  type = any
  default = {
    limits = {
      cpu    = "500m",
      memory = "512Mi"
    },
    requests = {
      cpu    = "100m",
      memory = "128Mi"
    }
  }
}
