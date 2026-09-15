class GeocodeTargetAreaValidator
  attr_reader :field_map

  def initialize(**options)
    @field_map = options.fetch(:field_map) { FieldDefinitions::GeocodeFieldMap }
  end

  def valid?(data)
    return false unless data.is_a?(Hash)
    return false unless data.keys.all? { field_map.field_names.include?(it.to_sym) }

    hierarchy = data.select { |_k, v| v.present? }.keys

    levels = hierarchy.map { field_map.to_administrative_level(it) }.sort

    return false if levels.empty?

    levels == (1..levels.size).to_a
  end
end
