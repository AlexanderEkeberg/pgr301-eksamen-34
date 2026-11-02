resource "aws_cloudwatch_metric_alarm" "bedrock_slow" {
  alarm_name  = "wishifai-${var.candidate_number}-bedrock-slow"
  namespace   = "wishifai-${var.candidate_number}"
  metric_name = "bedrock_duration.avg"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 30000
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  treat_missing_data  = "notBreaching"

  alarm_description = "Bedrock bruker mer enn 30 sekunder i snitt i 3 minutter på rad"
}