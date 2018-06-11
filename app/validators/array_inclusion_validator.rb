class ArrayInclusionValidator < ActiveModel::EachValidator
  def initialize(options)
    @in = options[:in]
    super
  end

  def validate_each(record, attribute, value)
    return if (record.send(@in) & value) == value
    record.errors.add(attribute, :inclusion)
  end
end
