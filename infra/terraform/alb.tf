# alb_public: único componente expuesto a Internet (solo HTTPS 443).
resource "aws_lb" "alb_public" {
  #checkov:skip=CKV_AWS_91:Los access logs del ALB no admiten buckets cifrados con SSE-KMS; pendiente bucket dedicado
  #checkov:skip=CKV2_AWS_28:WAF pertenece a la etapa Operate (ModSecurity/WAF), fuera de la Sesion 11
  name                       = "securebank-alb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = aws_subnet.subnet_pub[*].id
  security_groups            = [aws_security_group.sg_public.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "api" {
  name     = "securebank-api"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  health_check {
    path = "/welcome"
  }
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.ec2_web.id
  port             = 8000
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb_public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
