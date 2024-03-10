resource "aws_cloudwatch_log_group" "ecs_log_group_service_a" {
  name = "/ecs/nginx-service-a-container"
  # Optional: You can add additional configurations for the log group if needed
  # retention_in_days = 3
  # kms_key_id = aws_kms_key.example.key_id
  # tags = {
  #   Environment = "Production"
  # }
}

resource "aws_cloudwatch_log_group" "ecs_log_group_router" {
  name = "/ecs/nginx-router-container"
  # Optional: You can add additional configurations for the log group if needed
  # retention_in_days = 3
  # kms_key_id = aws_kms_key.example.key_id
  # tags = {
  #   Environment = "Production"
  # }
}

resource "aws_cloudwatch_log_group" "ecs_log_group_service_b" {
  name = "/ecs/nginx-service-b-container"
}