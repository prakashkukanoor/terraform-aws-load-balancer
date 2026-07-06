locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }

  applications_data = flatten([
    for domain_name, domain_data in var.applications : [
      for alb_data in domain_data.application_load_balancer : {
        name            = alb_data.name
        type            = alb_data.type
        internal        = alb_data.internal
        subnets         = alb_data.subnets
        security_groups = alb_data.security_groups
        nodeport        = alb_data.nodeport
        listener_port   = alb_data.listener_port
      }
    ]
  ])
}

resource "aws_lb" "this" {
  for_each           = local.applications_data
  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = each.value.type
  subnets            = each.value.subnets

  # ALBs require security groups, NLBs do not.
  # If type is network, we safely assign null to security groups.
  security_groups = each.value.type == "application" ? each.value.security_groups : null
}