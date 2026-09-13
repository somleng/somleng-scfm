class TargetAreaDataType < ActiveRecord::Type::Json
  TargetAreas = Data.define(:geocode) do
    def self.blank
      new(geocode: [])
    end

    def as_json
      { "geocode" => geocode.map(&:as_json) }
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
    return TargetAreas.blank if value.blank?
    return value if value.is_a?(TargetAreas)

    geocode_areas = Array(value.with_indifferent_access[:geocode]).map do |area|
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

  def administrative_level_for(field_name)
    FieldDefinitions::GeocodeFieldMap.to_administrative_level(field_name)
  end
end
