class ApplicationJob < ActiveJob::Base
  DEFAULT_QUEUE_NAME = "default"

  def self.aws_sqs_queue_name(job_name = nil)
    eb_tier = Rails.application.secrets.fetch(:eb_tier)

    if eb_tier.casecmp?("worker") && aws_sqs_queue_url(job_name).blank?
      DEFAULT_QUEUE_NAME
    else
      aws_sqs_queue_url(job_name).split("/").last
    end
  end

  def self.aws_sqs_queue_url(job_name = nil)
    Rails.application.secrets[:"#{job_name || to_s.underscore}_queue_url"] ||
      Rails.application.secrets.fetch(:default_queue_url)
  end

  queue_as(aws_sqs_queue_name)
end
