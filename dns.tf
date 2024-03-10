
resource "aws_route53_zone" "my_phz" {
  name = "nginx.com"      # replace with your desired zone name

  vpc {
    vpc_id = aws_vpc.main.id     # replace with your VPC id
  }
}

resource "aws_route53_record" "service-a" {
  zone_id = aws_route53_zone.my_phz.id
  name    = "service-a.nginx.com"
  type    = "CNAME"
  ttl     = 15
  records = [aws_lb.nginx-service-a-alb.dns_name]
}

resource "aws_route53_record" "service-b" {
  zone_id = aws_route53_zone.my_phz.id
  name    = "service-b.nginx.com"
  type    = "CNAME"
  ttl     = 15
  records = [aws_lb.nginx-service-b-alb.dns_name]
}

resource "aws_route53_health_check" "service-a-hc" {
  fqdn              = aws_lb.nginx-service-a-alb.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = 10

  tags = {
    Name = "service-a health check"
  }
}

resource "aws_route53_record" "service-a-balanced" {
  zone_id = aws_route53_zone.my_phz.id
  name    = "service.nginx.com"
  type    = "CNAME"
  ttl     = 2

  set_identifier = "service-a"

  records = [aws_lb.nginx-service-a-alb.dns_name]

  weighted_routing_policy {
    weight  = 50
  }

  health_check_id = aws_route53_health_check.service-a-hc.id

}

resource "aws_route53_health_check" "service-b-hc" {
  fqdn              = aws_lb.nginx-service-b-alb.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = 10

  tags = {
    Name = "service-b health check"
  }
}

resource "aws_route53_record" "service-b-balanced" {
  zone_id = aws_route53_zone.my_phz.id
  name    = "service.nginx.com"
  type    = "CNAME"
  ttl     = 2

  set_identifier = "service-b"

  records = [aws_lb.nginx-service-b-alb.dns_name]

  weighted_routing_policy {
    weight  = 50
  }

  health_check_id = aws_route53_health_check.service-b-hc.id

}


