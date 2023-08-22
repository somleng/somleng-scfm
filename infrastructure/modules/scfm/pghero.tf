resource "aws_cloudwatch_event_rule" "scheduler_pg_hero_capture_query_stats_job" {
  name                = "${var.app_identifier}-SchedulerJob-pg-hero-capture_query_stats"
  schedule_expression =  "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_pg_hero_capture_query_stats_job" {
  target_id = aws_cloudwatch_event_rule.scheduler_pg_hero_capture_query_stats_job.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_pg_hero_capture_query_stats_job.name

  input = <<DOC
{
  "job_class": "PgheroCaptureQueryStatsJob"
}
DOC
}
