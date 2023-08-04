class RetryPhoneCallJob < ApplicationJob
  RETRY_CALL_STATUSES = %i[not_answered busy failed].freeze
  IN_PROGRESS_CALL_STATUSES = %i[created queued remotely_queued in_progress].freeze

  def perform(phone_call)
    callout_participation = phone_call.callout_participation

    return if callout_participation.answered?
    return if max_calls_reached?(callout_participation)
    return if in_progress_calls?(callout_participation)

    PhoneCall.create!(
      account: phone_call.account,
      callout_participation:,
      contact: phone_call.contact,
      callout: phone_call.callout
    )
  end

  private

  def max_calls_reached?(callout_participation)
    callout_participation.phone_calls.where(status: RETRY_CALL_STATUSES).count >=
      callout_participation.account.max_phone_calls_for_callout_participation
  end

  def in_progress_calls?(callout_participation)
    callout_participation.phone_calls.where(status: IN_PROGRESS_CALL_STATUSES).any?
  end
end
