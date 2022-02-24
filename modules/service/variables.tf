variable "metadata" {
  type = map(any)
}

variable "spec" {
  type = map(any)
}

variable "metric" {
  type    = string
  default = "concurrency"
}

variable "target" {
  type    = string
  default = null
}

variable "min_scale" {
  type    = number
  default = 0
}

variable "max_scale" {
  type    = number
  default = 3
}
