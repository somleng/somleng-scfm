class RetryPhoneCallJob < ApplicationJob
  def perform(phone_call)
    PhoneCall.create!(
      account: phone_call.account,
      callout_participation: phone_call.callout_participation,
      contact: phone_call.contact
    )
  end
end
