class GeocodeTargetAreaValidator
  def valid?(data)
    hierarchy = data.select { |_k, v| v.present? }.keys
    levels = hierarchy.map { FieldDefinitions::GeocodeFieldMap.to_administrative_level(it) }.sort

    levels == (1..levels.size).to_a
  end
end
