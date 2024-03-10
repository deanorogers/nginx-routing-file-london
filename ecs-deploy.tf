#####################################
## Service A deployment
#####################################
resource "aws_codedeploy_app" "service-a-codedeployapp" {
    compute_platform = "ECS"
    name = "serviceacodedeployapp"
}
resource "aws_codedeploy_deployment_group" "service-a-codedeploygroup" {
  app_name              = aws_codedeploy_app.service-a-codedeployapp.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name = "serviceacodedeploygroup"
  service_role_arn      = aws_iam_role.eu2-nginxRouterEcsCodeDeployRole.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

   ecs_service {
    cluster_name = aws_ecs_cluster.nginx-router.name
    service_name = aws_ecs_service.nginx-service-a.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.nginx-service-a-listener.arn]
      }

      target_group {
        name = aws_lb_target_group.nginx-service-a-tg-blue.name
      }

      target_group {
        name = aws_lb_target_group.nginx-service-a-tg-green.name
      }
    }
  }

}

#####################################
## Router deployment
#####################################
resource "aws_codedeploy_app" "router-codedeployapp" {
  compute_platform = "ECS"
  name = "routercodedeployapp"
}
resource "aws_codedeploy_deployment_group" "router-codedeploygroup" {
  app_name              = aws_codedeploy_app.router-codedeployapp.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name = "routercodedeploygroup"
  service_role_arn      = aws_iam_role.eu2-nginxRouterEcsCodeDeployRole.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.nginx-router.name
    service_name = aws_ecs_service.nginx-router.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.nginx-router-listener.arn]
      }

      target_group {
        name = aws_lb_target_group.nginx-router-tg-blue.name
      }

      target_group {
        name = aws_lb_target_group.nginx-router-tg-green.name
      }
    }
  }

}

#####################################
## Service B deployment
#####################################
resource "aws_codedeploy_app" "service-b-codedeployapp" {
  compute_platform = "ECS"
  name = "servicebcodedeployapp"
}
resource "aws_codedeploy_deployment_group" "service-b-codedeploygroup" {
  app_name              = aws_codedeploy_app.service-b-codedeployapp.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name = "servicebcodedeploygroup"
  service_role_arn      = aws_iam_role.eu2-nginxRouterEcsCodeDeployRole.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.nginx-router.name
    service_name = aws_ecs_service.nginx-service-b.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.nginx-service-b-listener.arn]
      }

      target_group {
        name = aws_lb_target_group.nginx-service-b-tg-blue.name
      }

      target_group {
        name = aws_lb_target_group.nginx-service-b-tg-green.name
      }
    }
  }

}