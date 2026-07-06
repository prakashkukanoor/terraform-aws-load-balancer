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

variable "applications" {
  type = map(object({
    name            = string
    type            = string
    internal        = bool
    subnets         = list(string)
    security_groups = list(string)
    nodeport        = number
    listener_port   = number
  }))
  default = {
  }
  description = "Application loadbalancer for your eks cluster"
}