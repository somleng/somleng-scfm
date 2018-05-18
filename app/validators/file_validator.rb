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
      wrong_file_type?(record, attribute, value)
      oversize?(record, attribute, value)
    elsif @presence
      record.errors.add(attribute, :blank)
    end
  end

  private

  def wrong_file_type?(record, attribute, value)
    return unless @type && !value.blob.content_type.in?(@type)
    record.errors.add(attribute, :file_type)
  end

  def oversize?(record, attribute, value)
    return unless @size && value.blob.byte_size.bytes > @size
    record.errors.add(
      attribute, :file_size, size: number_to_human_size(@size)
    )
  end
end
