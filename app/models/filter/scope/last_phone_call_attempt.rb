class Filter::Scope::LastPhoneCallAttempt < Filter::Base
  def apply
    association_chain.last_phone_call_attempt(split_filter_values(last_phone_call_attempt_params))
  end

  def apply?
    last_phone_call_attempt_params.present?
  end

  private

  def last_phone_call_attempt_params
    params[:last_phone_call_attempt]
  end
end
