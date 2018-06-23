class Filter::Scope::HavingMaxPhoneCallsCount < Filter::Base
  def apply
    association_chain.having_max_phone_calls_count(having_max_phone_calls_count_params)
  end

  def apply?
    having_max_phone_calls_count_params.present?
  end

  private

  def having_max_phone_calls_count_params
    params[:having_max_phone_calls_count]
  end
end
