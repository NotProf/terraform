module "labels" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  context = var.context
  name    = var.name
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = module.labels.id

  slack_webhook_url = "https://hooks.slack.com/services/K/K"
  slack_channel     = "aws"
  slack_username    = "igorK"
}

resource "aws_budgets_budget" "this" {
  name = module.labels.id
  budget_type = "COST"
  limit_amount = "1.0"
  limit_unit = "USD"
  time_period_start = "2021-05-01_00:00"
  time_unit = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type = "FORECASTED"
    threshold = 1.0
    threshold_type = "ABSOLUTE_VALUE"
    subscriber_email_addresses = [var.email_address]
    subscriber_sns_topic_arns = [module.notify_slack.this_slack_topic_arn]
  }
}
