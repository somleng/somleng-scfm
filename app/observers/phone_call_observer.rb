class PhoneCallObserver < ApplicationObserver
  def phone_call_queued(phone_call)
    QueueRemoteCallJob.perform_later(phone_call.id)
  end

  def phone_call_remote_fetch_queued(phone_call)
    FetchRemoteCallJob.perform_later(phone_call.id)
  end
end
