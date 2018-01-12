class ApplicationJob < ActiveJob::Base
  DEFAULT_QUEUE_NAME = "default"

  queue_as(queue_name)

  def self.queue_name(job_name = nil)
    ENV[[:active_job, job_name || self.name.underscore, :queue_name].join("_").upcase] ||
    ENV["ACTIVE_JOB_QUEUE_NAME"] ||
    DEFAULT_QUEUE_NAME
  end
end
