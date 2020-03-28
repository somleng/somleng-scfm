resource "aws_lb_target_group" "this" {
  count = 2
  name = "${var.app_identifier}-${count.index}"
  port = var.webserver_container_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  deregistration_delay = 60

  health_check {
    protocol = "HTTP"
    path = "/health_checks"
    healthy_threshold = 3
    interval = 10
  }
}

resource "aws_lb" "this" {
  name = var.app_identifier
  load_balancer_type = var.load_balancer_type
  subnets = var.load_balancer_subnets
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = var.logs_bucket
    prefix  = var.app_identifier
    enabled = true
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.id
  port = var.load_balancer_port
  protocol = var.load_balancer_protocol
  ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn = var.load_balancer_ssl_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.this[0].id
    type = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}