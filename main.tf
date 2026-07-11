locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }
}

resource "aws_lb" "this" {
  name               = "${var.cluster_name}-lb"
  internal           = var.is_lb_internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets

  tags = merge(
    local.common_tags,
  { Name = "${var.cluster_name}-lb" })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.cluster_name}-tg"
  port        = var.ingress_node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  # Intelligent Routing Algorithm
  load_balancing_algorithm_type = var.load_balancing_algorithm_type

  health_check {
    enabled             = true
    path                = "/healthz" # The health endpoint of your app
    protocol            = "HTTP"
    port                = var.ingress_node_port
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.acm_certificate_arn # Your AWS SSL Certificate ARN

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this.arn
#   }
# }

resource "aws_autoscaling_attachment" "asg_lb_link" {
  autoscaling_group_name = var.eks_worker_asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}