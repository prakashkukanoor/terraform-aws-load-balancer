locals {
  load_balancer_name = "${var.cluster_name}-lb"
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }
}

resource "aws_lb" "this" {
  name               = local.load_balancer_name
  internal           = var.is_lb_internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets
  security_groups    = [aws_security_group.this.id]

  tags = merge(
    local.common_tags,
  { Name = "${var.cluster_name}-lb" })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.cluster_name}-tg"
  port        = var.envoy_healthcheck_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  # Intelligent Routing Algorithm
  load_balancing_algorithm_type = var.load_balancing_algorithm_type

  health_check {
    enabled             = true
    path                = "/ready" # The health endpoint of your app
    protocol            = "HTTP"
    port                = "traffic-port" 
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
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "asg_lb_link" {
  autoscaling_group_name = var.eks_worker_asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
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