provider "aws" {}


###############################################
# DATA
###############################################
#data "aws_ssm_parameter" "ami" {
#  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#}

data "aws_availability_zones" "available" {
    state = "available"
}
  

###############################################
# RESOURCES
###############################################

# NETWORKING #

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = local.common_tags
    
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = local.common_tags
}

resource "aws_subnet" "subnet1" {
    cidr_block = var.vpc_subnets_cidr_block[0]
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = var.map_public_ip_on_launch
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = local.common_tags
}

resource "aws_subnet" "subnet2" {
    cidr_block = var.vpc_subnets_cidr_block[1]
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = var.map_public_ip_on_launch
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = local.common_tags
}

# ROUTING #

resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = local.common_tags
}

resource "aws_route_table_association" "rta-subnet1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rta-subnet2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #

######################
# router service ALB
# allow traffic from my local IP
######################
resource "aws_security_group" "router-alb-sg" {
    name = "router-alb-sg"
    vpc_id = aws_vpc.main.id
    tags = local.common_tags
}
resource "aws_security_group_rule" "router-alb-sg-rule-ingress-rule-1" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.router-alb-sg.id
    cidr_blocks = ["92.40.215.220/32"] # my public IP
}
resource "aws_security_group_rule" "upstream-alb-sg-rule-egress-rule-2" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.router-alb-sg.id
}
###################
# router service
###################
resource "aws_security_group" "router-service-sg" {
    name = "router-service-sg"
    vpc_id = aws_vpc.main.id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = local.common_tags
}
# accept traffic from either ALB on ports 8081 to 8082
resource "aws_security_group_rule" "router-service-sg-rule-1" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.router-service-sg.id
    source_security_group_id = aws_security_group.router-alb-sg.id
}

######################
# upstream service ALB
# allow traffic from the nginx-router SG (rule 2)
# and from my local IP (rule 1) for testing
######################
resource "aws_security_group" "upstream-alb-sg" {
    name = "upstream-alb-sg"
    vpc_id = aws_vpc.main.id
    tags = local.common_tags
}
resource "aws_security_group_rule" "upstream-alb-sg-rule-ingress-rule-1" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.upstream-alb-sg.id
    cidr_blocks = ["92.40.215.220/32"] # my public IP
}

resource "aws_security_group_rule" "upstream-alb-sg-rule-ingress-rule-2" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.upstream-alb-sg.id
    source_security_group_id = aws_security_group.router-service-sg.id
}
resource "aws_security_group_rule" "upstream-alb-sg-rule-egress-rule-3" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.upstream-alb-sg.id
}

###################
# upstream services
###################
resource "aws_security_group" "upstream-service-sg" {
    name = "upstream-service-sg"
    vpc_id = aws_vpc.main.id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = local.common_tags
}
# accept traffic from either ALB on ports 8080 to 8082
resource "aws_security_group_rule" "upstream-service-sg-rule-1" {
    type = "ingress"
    from_port = 8080
    to_port = 8082
    protocol = "tcp"
    security_group_id = aws_security_group.upstream-service-sg.id
    source_security_group_id = aws_security_group.upstream-alb-sg.id
}

###############################################
# OUTPUTS (could be in a separate outputs.tf file)
###############################################









