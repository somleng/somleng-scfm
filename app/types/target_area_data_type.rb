class TargetAreaDataType < ActiveRecord::Type::Json
  TargetAreas = Data.define(:geocode) do
    def self.blank
      new(geocode: [])
    end

    def as_json
      { "geocode" => geocode.map(&:as_json) }
    end

    def blank?
      geocode.blank?
    end
  end

  AdministrativeArea = Data.define(:hierarchy) do
    def path
      hierarchy.map(&:geocode)
    end

    def level
      path.size
    end

    def division
      hierarchy.last
    end

    def as_json
      hierarchy.to_h { [ it.field_name, it.geocode ] }
    end
  end

  AdministrativeDivision = Data.define(:field_name, :geocode, :level)

  def cast(value)
    return value if value.is_a?(TargetAreas)

    value = parse_json(value) if value.is_a?(::String)

    return TargetAreas.blank if value.blank? || !value.is_a?(Hash)

    payload = value.with_indifferent_access
    return TargetAreas.blank unless payload[:geocode].is_a?(Array)

    geocode_areas = payload.fetch(:geocode).map do |area|
      return TargetAreas.blank unless area.is_a?(Hash)
      return TargetAreas.blank unless area.keys.all? { administrative_level_fields.include?(it.to_s) }

      hierarchy = area.map do |field_name, value|
        AdministrativeDivision.new(
          field_name:,
          geocode: value,
          level: administrative_level_for(field_name)
        )
      end
      AdministrativeArea.new(hierarchy: hierarchy.sort_by(&:level))
    end

    TargetAreas.new(geocode: geocode_areas)
  end

  def serialize(value)
    super(cast(value).as_json)
  end

  def deserialize(value)
    cast(super)
  end

  private

  def parse_json(value)
    ActiveSupport::JSON.decode(value)
  rescue JSON::ParserError
    nil
  end

  def administrative_level_for(field_name)
    FieldDefinitions::GeocodeFieldMap.to_administrative_level(field_name)
  end

  def administrative_level_fields
    FieldDefinitions::GeocodeFieldMap.fields.map { it.name.to_s }
  end
end
