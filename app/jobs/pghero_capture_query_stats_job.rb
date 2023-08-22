class PgheroCaptureQueryStatsJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_low_priority_queue_name)

  def perform
    PgHero.capture_query_stats
  end
end
