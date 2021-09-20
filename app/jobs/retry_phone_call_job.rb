class RetryPhoneCallJob < ApplicationJob
  RETRY_CALL_STATUSES = %i[not_answered busy failed].freeze
  IN_RUNNING_CALL_STATUSES = %i[created queued remotely_queued in_progress].freeze

  def perform(phone_call)
    callout_participation = phone_call.callout_participation

    return if callout_participation.answered?
    return if callout_participation.phone_calls.where(status: RETRY_CALL_STATUSES).count >= phone_call.account.max_phone_calls_for_callout_participation
    return if phone_call.callout_participation.phone_calls.where(status: IN_RUNNING_CALL_STATUSES).exists?

    PhoneCall.create!(
      account: phone_call.account,
      callout_participation: callout_participation,
      contact: phone_call.contact,
      callout: phone_call.callout
    )
  end
end
