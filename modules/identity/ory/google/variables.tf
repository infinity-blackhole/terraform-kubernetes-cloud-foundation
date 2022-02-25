variable "name" {
  type    = string
  default = "oathkeeper"
}

variable "namespace" {
  type    = string
  default = "default"
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
  type    = map(string)
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
  default = "oryd/oathkeeper"
}

variable "config" {
  type    = any
  default = {}
}

variable "access_rules" {
  type    = map(any)
  default = {}
}

variable "region" {
  type = string
}
