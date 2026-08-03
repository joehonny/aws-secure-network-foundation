data "aws_caller_identity" "current" {
  count = var.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = var.enabled ? 1 : 0
}

locals {
  account_id = var.enabled ? data.aws_caller_identity.current[0].account_id : null
  partition  = var.enabled ? data.aws_partition.current[0].partition : null
  region     = var.enabled ? data.aws_region.current[0].region : null

  assume_role_policy = var.enabled ? jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowVPCFlowLogsService"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = local.account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:${local.partition}:ec2:${local.region}:${local.account_id}:vpc-flow-log/*"
        }
      }
    }]
  }) : null
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.enabled ? 1 : 0

  name              = "/aws/vpc-flow-logs/${var.name_prefix}"
  retention_in_days = var.retention_days

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

resource "aws_iam_role" "this" {
  count = var.enabled ? 1 : 0

  name_prefix        = "${var.name_prefix}-vpc-flow-logs-"
  assume_role_policy = local.assume_role_policy

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

resource "aws_iam_role_policy" "this" {
  count = var.enabled ? 1 : 0

  name_prefix = "${var.name_prefix}-vpc-flow-logs-"
  role        = aws_iam_role.this[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteToDedicatedLogGroup"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.this[0].arn}:*"
      },
      {
        Sid      = "DescribeLogDelivery"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups", "logs:DescribeLogStreams"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.enabled ? 1 : 0

  vpc_id                   = var.vpc_id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.this[0].arn
  iam_role_arn             = aws_iam_role.this[0].arn
  max_aggregation_interval = 60

  depends_on = [aws_iam_role_policy.this]

  tags = {
    Name = "${var.name_prefix}-vpc-flow-log"
  }
}
