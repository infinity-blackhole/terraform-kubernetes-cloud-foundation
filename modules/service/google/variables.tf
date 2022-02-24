variable "name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "args" {
  type    = list(string)
  default = null
}

variable "command" {
  type    = list(string)
  default = null
}

variable "concurrency" {
  type    = number
  default = null
}

variable "cpu" {
  type    = string
  default = null
}

variable "max_instances" {
  type    = number
  default = null
}

variable "memory" {
  type    = string
  default = null
}

variable "min_instances" {
  type    = number
  default = null
}

variable "port" {
  type    = number
  default = null
}

variable "service_account_name" {
  type    = string
  default = null
}

variable "timeout" {
  type    = number
  default = null
}

variable "env" {
  type    = list(string)
  default = null
}

variable "labels" {
  type    = map(string)
  default = null
}

variable "annotations" {
  type    = map(string)
  default = null
}

variable "image" {
  type    = string
  default = null
}

variable "volumes" {
  type    = list(any)
  default = null
}

variable "volume_mounts" {
  type    = list(any)
  default = null
}

# Platform specific variables

variable "region" {
  type = string
}

variable "protocol_version" {
  type    = string
  default = "h2c"
}

variable "sandbox" {
  type    = string
  default = "gvisor"
}
