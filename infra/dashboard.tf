resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "wishifai-${var.candidate_number}"
  dashboard_body = <<GREEN_PIPELINE
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Tid brukt på Bedrock og Rekognition",
        "metrics": [
          ["wishifai-${var.candidate_number}", "bedrock_duration.avg"],
          ["wishifai-${var.candidate_number}", "rekognition_duration.avg"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.region}"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Gaveforslag per bilde",
        "metrics": [
          ["wishifai-${var.candidate_number}", "gift_suggestions_per_request.avg"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.region}"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "ECS CPU og minne",
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ClusterName", "default", "ServiceName", "wishifai-${var.candidate_number}"],
          ["AWS/ECS", "MemoryUtilization", "ClusterName", "default", "ServiceName", "wishifai-${var.candidate_number}"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.region}"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Prosess-CPU i appen (Actuator)",
        "metrics": [
          ["wishifai-${var.candidate_number}", "process.cpu.usage.value"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.region}"
      }
    }
  ]
}
GREEN_PIPELINE
}