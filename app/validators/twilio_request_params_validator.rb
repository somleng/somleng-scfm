class TwilioRequestParamsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return record.errors.add(attribute, :invalid) unless value.is_a?(Hash)
    return if (value.keys - allowed_parameters).empty?

    record.errors.add(attribute, :inclusion)
  end

  private

  def allowed_parameters
    Twilio::REST::Client.new.api.account.calls.method(:create).parameters.map { |param| param[1].to_s }
  end
end
