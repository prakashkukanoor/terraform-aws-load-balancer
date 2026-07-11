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

variable "subnets" {
  type = list(string)
}

variable "eks_worker_asg_id" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "load_balancing_algorithm_type" {
  type    = string
  default = "least_outstanding_requests"
}

variable "ingress_node_port" {
  type = number
}

variable "is_lb_internal" {
  type = bool
}

variable "vpc_id" {
  type    = string
  default = "instance"
}

variable "target_type" {
  type = string
}