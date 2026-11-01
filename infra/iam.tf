data "aws_iam_policy_document" "ecs_tasks_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }

  statement {
    actions   = ["rekognition:DetectLabels"]
    resources = ["*"]
  }

  statement {
    actions   = ["bedrock:InvokeModel"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "wishifai-task-role-${var.candidate_number}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

resource "aws_iam_role_policy" "task_permissions" {
  name   = "wishifai-task-permissions-${var.candidate_number}"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.task_permissions.json
}