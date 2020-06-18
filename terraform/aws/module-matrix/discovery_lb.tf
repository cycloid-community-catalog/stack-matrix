#
# Used to forward <DOMAIN>/.well-known/matrix/{server,client} requests from the ALB
# handling the matrix base domain to the matrix server
#

# alb target group
resource "aws_alb_target_group" "server-80" {
  count    = var.create_external_alb_discovery_listener_rule ? 1 : 0
  name     = length(replace("${var.project}${var.env}matrix80", var.nameregex, "")) > 32 ? "${local.default_short_name}matrix80" : replace("${var.project}${var.env}server80", var.nameregex, "")
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = var.external_alb_health_check_path
    matcher  = var.external_alb_health_check_matcher
    timeout  = var.external_alb_health_check_timeout
    interval = var.external_alb_health_check_interval
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
}

resource "aws_alb_listener_rule" "discovery" {
  count        = var.create_external_alb_discovery_listener_rule ? 1 : 0
  listener_arn = var.external_alb_discovery_listener_arn

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.server-80[0].arn
  }

  condition {
    path_pattern {
      values = [
        "/.well-known/matrix/*",
      ]
    }
  }
}