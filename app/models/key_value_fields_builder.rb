class KeyValueFieldsBuilder
  def from_attributes(attributes)
    collection = []

    attributes.each do |_i, metadata_form_params|
      collection << KeyValueField.new(metadata_form_params)
    end

    collection.reject(&:empty?)
  end

  def from_nested_hash(hash)
    flatten_hash(hash).map do |k, v|
      KeyValueField.new(key: k, value: v)
    end
  end

  def to_h(collection)
    collection.map(&:to_json).reject(&:blank?).reduce({}, :deep_merge)
  end

  private

  def flatten_hash(hash)
    Hash[flat_hash(hash).map { |k, v| [k.join(KeyValueField::KEY_DELIMITER), v] }]
  end

  # https://stackoverflow.com/a/23861946
  def flat_hash(h, f = [], g = {})
    return g.update(f => h) unless h.is_a? Hash
    h.each { |k, r| flat_hash(r, f + [k], g) }
    g
  end
end
