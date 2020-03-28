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
