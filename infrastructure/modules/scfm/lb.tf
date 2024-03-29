resource "aws_lb_target_group" "webserver" {
  name = var.app_identifier
  port = var.webserver_container_port
  protocol = "HTTP"
  vpc_id = var.vpc.vpc_id
  target_type = "ip"
  deregistration_delay = 60

  health_check {
    protocol = "HTTP"
    path = "/health_checks"
    healthy_threshold = 3
    interval = 10
  }
}

resource "aws_lb_listener_rule" "webserver" {
  priority = 10

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.id
  }

  condition {
    host_header {
      values = [aws_route53_record.app.fqdn]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}
