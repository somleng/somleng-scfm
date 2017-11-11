class PhoneCallObserver < ApplicationObserver
  def phone_call_queued(phone_call)
    QueueRemoteCallJob.perform_later(phone_call.id)
  end
end
