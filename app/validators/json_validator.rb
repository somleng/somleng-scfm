class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !value.is_a?(Hash)
      record.errors.add(attribute, :invalid)
    end
  end
end
