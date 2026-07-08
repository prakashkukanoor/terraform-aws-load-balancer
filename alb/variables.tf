variable "region" {
  type        = string
  description = "region for bucket creation"
  default     = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}
variable "team" {
  type    = string
  default = "devops"
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
  default = "instance"
}

variable "target_type" {
  type = string
}


variable "applications" {
  type = map(object({
    type            = string
    internal        = bool
    subnets         = list(string)
    security_groups = list(string)
  }))
  default = {
  }
  description = "Application loadbalancer for your eks cluster"
}