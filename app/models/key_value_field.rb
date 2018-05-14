class KeyValueField
  KEY_DELIMITER = ":".freeze
  include ActiveModel::Model

  attr_accessor :key, :value, :_destroy

  def new_record?
    true
  end

  def marked_for_destruction?
    false
  end

  def empty?
    key.blank? || value.blank?
  end

  def to_json
    key.split(KEY_DELIMITER).reverse.inject(value) { |v, k| { k => v } }
  end
end
