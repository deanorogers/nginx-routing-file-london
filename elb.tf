####################################
# service-a
####################################
resource "aws_lb" "nginx-service-a-alb" {
    name = "nginx-service-a-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.upstream-alb-sg.id]
    enable_deletion_protection = false
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    tags = local.common_tags
}
resource "aws_lb_target_group" "nginx-service-a-tg-blue" {
    name = "nginx-service-a-tg-blue"
    port = 8081
    protocol = "HTTP"
    target_type = "ip"
    health_check {
      path = "/"
      port = 8081
    }
    vpc_id = aws_vpc.main.id
}
# 2nd ALB TG for blue/green deployments
resource "aws_lb_target_group" "nginx-service-a-tg-green" {
    name = "nginx-service-a-tg-green"
    port = 8081
    protocol = "HTTP"
    target_type = "ip"
    health_check {
      path = "/"
      port = 8081
    }
    vpc_id = aws_vpc.main.id
}
## aws_lb_listener
resource "aws_lb_listener" "nginx-service-a-listener" {
    load_balancer_arn = aws_lb.nginx-service-a-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.nginx-service-a-tg-blue.arn
    }
}

####################################
# router
####################################
resource "aws_lb" "nginx-router-alb" {
    name = "nginx-router-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.router-alb-sg.id]
    enable_deletion_protection = false
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    tags = local.common_tags
}
resource "aws_lb_target_group" "nginx-router-tg-blue" {
    name = "nginx-router-tg-blue"
    port = 8080
    protocol = "HTTP"
    target_type = "ip"
    health_check {
        path = "/"
        port = 8080
    }
    vpc_id = aws_vpc.main.id
}
# 2nd ALB TG for blue/green deployments
resource "aws_lb_target_group" "nginx-router-tg-green" {
    name = "nginx-router-tg-green"
    port = 8080
    protocol = "HTTP"
    target_type = "ip"
    health_check {
        path = "/"
        port = 8080
    }
    vpc_id = aws_vpc.main.id
}
## aws_lb_listener
resource "aws_lb_listener" "nginx-router-listener" {
    load_balancer_arn = aws_lb.nginx-router-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.nginx-router-tg-blue.arn
    }
}

####################################
# service-b
####################################
resource "aws_lb" "nginx-service-b-alb" {
    name = "nginx-service-b-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.upstream-alb-sg.id]
    enable_deletion_protection = false
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    tags = local.common_tags
}
resource "aws_lb_target_group" "nginx-service-b-tg-blue" {
    name = "nginx-service-b-tg-blue"
    port = 8082
    protocol = "HTTP"
    target_type = "ip"
    health_check {
        path = "/"
        port = 8082
    }
    vpc_id = aws_vpc.main.id
}
# 2nd ALB TG for blue/green deployments
resource "aws_lb_target_group" "nginx-service-b-tg-green" {
    name = "nginx-service-b-tg-green"
    port = 8082
    protocol = "HTTP"
    target_type = "ip"
    health_check {
        path = "/"
        port = 8082
    }
    vpc_id = aws_vpc.main.id
}
## aws_lb_listener
resource "aws_lb_listener" "nginx-service-b-listener" {
    load_balancer_arn = aws_lb.nginx-service-b-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.nginx-service-b-tg-blue.arn
    }
}

output "service-a-dns" {
    value = aws_lb.nginx-service-a-alb.dns_name
}