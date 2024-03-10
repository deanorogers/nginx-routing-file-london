
data "aws_vpc" "main" {
  id = aws_vpc.main.id
}

resource "aws_ecs_cluster" "nginx-router" {
    name = "nginx-router-cluster"
}

######################################################
# service-a
######################################################
resource "aws_ecs_task_definition" "nginx-service-a" {
  family = "nginx-service-a"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "arn:aws:iam::107404535822:role/eu2-ecsTaskExecutionRole"
  # execution_role_arn = "arn:aws:iam::107404535822:role/MyAmazonECSServiceRole"
  # Needed to read Secret
  # execution_role_arn = "arn:aws:iam::107404535822:role/eu2-nginxRouterEcsCodeDeployRole"
  network_mode = "awsvpc"
  cpu = 1024 
  memory = 2048
  container_definitions = jsonencode([
    {
      name      = "nginx-service-a-container"
      image     = "107404535822.dkr.ecr.eu-west-2.amazonaws.com/nginx-service-a:latest"
      essential = true      
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/nginx-service-a-container"
          awslogs-region = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "nginx-service-a" {
  name = "nginx-service-a"
  cluster = aws_ecs_cluster.nginx-router.id
  task_definition = aws_ecs_task_definition.nginx-service-a.arn
  desired_count = 1
  launch_type = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  } 
  platform_version = "1.3.0"
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-service-a-tg-blue.arn
    container_name = "nginx-service-a-container"
    container_port = 8081
  }
  network_configuration {
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    security_groups = [aws_security_group.upstream-service-sg.id]
    assign_public_ip = true
  }
}
######################################################
# router
######################################################
resource "aws_ecs_task_definition" "nginx-router" {
  family = "nginx-router"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "arn:aws:iam::107404535822:role/eu2-ecsTaskExecutionRole"
  network_mode = "awsvpc"
  cpu = 1024
  memory = 2048
  container_definitions = jsonencode([
    {
      name      = "nginx-router-container"
      image     = "107404535822.dkr.ecr.eu-west-2.amazonaws.com/nginx-router:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/nginx-router-container"
          awslogs-region = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "nginx-router" {
  name = "nginx-router"
  cluster = aws_ecs_cluster.nginx-router.id
  task_definition = aws_ecs_task_definition.nginx-router.arn
  desired_count = 1
  launch_type = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  platform_version = "1.3.0"
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-router-tg-blue.arn
    container_name = "nginx-router-container"
    container_port = 8080
  }
  network_configuration {
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    security_groups = [aws_security_group.router-service-sg.id]
    assign_public_ip = true
  }
}

######################################################
# service-b
######################################################
resource "aws_ecs_task_definition" "nginx-service-b" {
  family = "nginx-service-b"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "arn:aws:iam::107404535822:role/eu2-ecsTaskExecutionRole"
  network_mode = "awsvpc"
  cpu = 1024
  memory = 2048
  container_definitions = jsonencode([
    {
      name      = "nginx-service-b-container"
      image     = "107404535822.dkr.ecr.eu-west-2.amazonaws.com/nginx-service-b:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8082
          hostPort      = 8082
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/nginx-service-b-container"
          awslogs-region = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "nginx-service-b" {
  name = "nginx-service-b"
  cluster = aws_ecs_cluster.nginx-router.id
  task_definition = aws_ecs_task_definition.nginx-service-b.arn
  desired_count = 1
  launch_type = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  platform_version = "1.3.0"
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-service-b-tg-blue.arn
    container_name = "nginx-service-b-container"
    container_port = 8082
  }
  network_configuration {
    subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
    security_groups = [aws_security_group.upstream-service-sg.id]
    assign_public_ip = true
  }
}