class ScheduledJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_high_priority_queue_name)

  def perform
    Account.find_each do |account|
      queue_phone_calls(account)
    end

    fetch_unknown_call_statuses
  end

  private

  def queue_phone_calls(account)
    phone_calls = PhoneCall.created.where(callout_id: account.callouts.running.select(:id))

    phone_calls.limit(account.phone_call_queue_limit).each do |phone_call|
      phone_call.queue!
      QueueRemoteCallJob.perform_later(phone_call)
    end
  end

  def fetch_unknown_call_statuses
    PhoneCall.to_fetch_remote_status.find_each do |phone_call|
      FetchRemoteCallJob.perform_later(phone_call)
      phone_call.touch(:remote_status_fetch_queued_at)
    end
  end
end
