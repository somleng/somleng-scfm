class FileValidator < ActiveModel::EachValidator
  include ActionView::Helpers::NumberHelper

  def initialize(options)
    @type     = options[:type]
    @size     = options[:size]
    @presence = options[:presence]
    super
  end

  def validate_each(record, attribute, value)
    if value.attached?
      validate_file_type(record, attribute, value)
      validate_file_size(record, attribute, value)
    elsif @presence
      record.errors.add(attribute, :blank)
    end
  end

  private

  def validate_file_type(record, attribute, value)
    return if @type.blank?
    return if value.blob.content_type.in?(@type)
    record.errors.add(attribute, :file_type)
  end

  def validate_file_size(record, attribute, value)
    return if @size.blank?
    return if value.blob.byte_size.bytes < @size
    record.errors.add(
      attribute, :file_size, size: number_to_human_size(@size)
    )
  end
end
