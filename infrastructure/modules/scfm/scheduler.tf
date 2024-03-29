resource "aws_iam_role" "app_scheduler" {
  name = "${var.app_identifier}-scheduler"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "app_scheduler" {
  name = "${var.app_identifier}-scheduler"
  role = aws_iam_role.app_scheduler.id

  policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.scheduler.arn}"
    }
  ]
}
DOC
}

resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "${var.app_identifier}-SchedulerJob"
  schedule_expression = "cron(* * * * ? *)"
  role_arn            = aws_iam_role.app_scheduler.arn
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = aws_cloudwatch_event_rule.scheduler.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler.name

  input = <<DOC
{
  "job_class": "ScheduledJob"
}
DOC
}

resource "aws_cloudwatch_event_rule" "scheduler_daily" {
  name                = "${var.app_identifier}-SchedulerJob-daily"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_daily" {
  target_id = aws_cloudwatch_event_rule.scheduler_daily.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_daily.name

  input = <<DOC
{
  "job_class": "DailyJob"
}
DOC
}
