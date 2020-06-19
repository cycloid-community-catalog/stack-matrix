#
# Used to forward <DOMAIN>/.well-known/matrix/{server,client} requests from the ALB
# handling the matrix base domain to the matrix server
#

resource "aws_alb_listener_rule" "discovery" {
  count        = var.create_external_alb_discovery_listener_rule ? 1 : 0
  listener_arn = var.external_alb_discovery_listener_arn

  action {
    type = "redirect"

    redirect {
      host        = var.external_alb_redirect_to_host
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = [
        "/.well-known/matrix/*",
      ]
    }
  }
}