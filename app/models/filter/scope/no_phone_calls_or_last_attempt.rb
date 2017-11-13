class Filter::Scope::NoPhoneCallsOrLastAttempt < Filter::Base
  def apply
    association_chain.no_phone_calls_or_last_attempt(
      split_filter_values(no_phone_calls_or_last_attempt_params)
    )
  end

  def apply?
    no_phone_calls_or_last_attempt_params.present?
  end

  private

  def no_phone_calls_or_last_attempt_params
    params[:no_phone_calls_or_last_attempt]
  end
end
