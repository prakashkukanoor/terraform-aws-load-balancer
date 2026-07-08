locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }

  applications_data = flatten([
    for domain_name, domain_data in var.applications : [
      for alb_data in domain_data.application_load_balancer : {
        type            = alb_data.type
        internal        = alb_data.internal
        subnets         = alb_data.subnets
        security_groups = alb_data.security_groups
      }
    ]
  ])
}

resource "aws_lb" "this" {
  for_each           = local.applications_data
  name               = "${var.cluster_name}-alb"
  internal           = each.value.internal
  load_balancer_type = each.value.type
  subnets            = each.value.subnets

  # ALBs require security groups, NLBs do not.
  # If type is network, we safely assign null to security groups.
  # security_groups = each.value.type == "application" ? each.value.security_groups : null
  tags = merge(
    local.common_tags,
  { Name = var.cluster_name })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.cluster_name}-target-group"
  port        = 30080    # The NodePort your application runs on inside EKS
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  # Intelligent Routing Algorithm
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    enabled             = true
    path                = "/healthz" # The health endpoint of your app
    protocol            = "HTTP"
    port                = "30080"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}