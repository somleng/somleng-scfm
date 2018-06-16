class ApplicationJob < ActiveJob::Base
  def self.aws_sqs_queue_name(job_name = nil)
    aws_sqs_queue_url(job_name).split("/").last
  end

  def self.aws_sqs_queue_url(job_name = nil)
    Rails.application.secrets[:"#{job_name || to_s.underscore}_queue_url"] ||
      Rails.application.secrets.fetch(:default_queue_url)
  end

  queue_as(aws_sqs_queue_name)
end
