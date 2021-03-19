class ScheduledJob < ApplicationJob
  UNKNOWN_PHONE_CALL_STATUSES = %i[remotely_queued in_progress].freeze

  def perform
    Account.find_each do |account|
      queue_phone_calls(account)
    end

    fetch_remote_phone_calls

    PhoneCall.expire!
  end

  private

  def queue_phone_calls(account)
    phone_calls = account.phone_calls
                         .created.joins(callout_participation: :callout)
                         .merge(Callout.running)
                         .limit(account.phone_call_queue_limit)

    phone_calls.find_each do |phone_call|
      phone_call.queue!
      QueueRemoteCallJob.perform_later(phone_call)
    end
  end

  def fetch_remote_phone_calls
    phone_calls = PhoneCall.where(status: UNKNOWN_PHONE_CALL_STATUSES).where("created_at < ?", 10.minutes.ago)
    phone_calls.find_each do |phone_call|
      FetchRemoteCallJob.perform_later(phone_call)
    end
  end
end
