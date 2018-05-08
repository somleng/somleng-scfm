class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(Array)
      record.errors.add(attribute, :invalid)
    end
  end
end
