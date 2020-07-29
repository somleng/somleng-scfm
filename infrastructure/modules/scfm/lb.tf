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

resource "aws_lb_listener_rule" "this" {
  count = 1
  priority = 10 + count.index

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[count.index].id
  }

  condition {
    host_header {
      values = ["scfm2.somleng.org"]
    }
  }

  ignore_changes = [action]
}