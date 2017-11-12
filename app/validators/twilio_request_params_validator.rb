class TwilioRequestParamsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && (!value.is_a?(Hash) || ((value || {}).keys - allowed_parameters).any?)
      record.errors.add(attribute, :inclusion)
    end
  end

  private

  def allowed_parameters
    @allowed_parameters ||= Somleng::Client.new.api.account.calls.method(:create).parameters.map { |param| param[1].to_s }
  end
end
