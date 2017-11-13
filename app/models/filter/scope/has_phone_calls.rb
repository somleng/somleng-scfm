class Filter::Scope::HasPhoneCalls < Filter::Base
  def apply
    if has_phone_calls?
      association_chain.has_phone_calls
    else
      association_chain.no_phone_calls
    end
  end

  def apply?
    has_phone_calls_params.present?
  end

  private

  def has_phone_calls?
    ActiveRecord::Type::Boolean.new.cast(has_phone_calls_params)
  end

  def has_phone_calls_params
    params[:has_phone_calls]
  end
end
