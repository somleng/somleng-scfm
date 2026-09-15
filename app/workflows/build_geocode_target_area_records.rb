class BuildGeocodeTargetAreaRecords < ApplicationWorkflow
  attr_reader :target_areas, :locality_data

  def initialize(target_areas, locality_data:)
    super()
    @target_areas = target_areas
    @locality_data = locality_data
  end

  def call
    target_areas.flat_map { expand_target_area(it) }.uniq { it[:path] }
  end

  private

  def expand_target_area(area)
    [ build_record(path: area.path), *subdivision_records_for(area) ]
  end

  def subdivision_records_for(area)
    locality_data.subdivisions_of(area.path).map { build_record(path: it.path) }
  end

  def build_record(path:)
    { path:, administrative_level: path.size, geocode: path.last }
  end
end
