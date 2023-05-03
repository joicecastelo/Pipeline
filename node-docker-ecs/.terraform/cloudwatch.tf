
resource "aws_cloudwatch_log_group" "dummy_api_log_group" {
    name = "/ecs/dummy_api"
  retention_in_days = 30

  tags = {
    Name = "cloudwatch-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "mydummy_log_stream" {
    name = "test-log-stream"
    log_group_name = aws_cloudwatch_log_group.dummy_api_log_group.name
  
}

