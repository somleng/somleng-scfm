module V1
  class TargetAreaSchema < ApplicationRequestSchema
    option :geocode_target_area_validator, default: -> { GeocodeTargetAreaValidator.new }

    params do
      required(:geocode).array(:hash) do
        required(:iso_region_code).filled(:string, max_size?: 255)
        optional(:administrative_division_level_2_code).maybe(:string, max_size?: 255)
        optional(:administrative_division_level_3_code).maybe(:string, max_size?: 255)
        optional(:administrative_division_level_4_code).maybe(:string, max_size?: 255)
        optional(:administrative_division_level_5_code).maybe(:string, max_size?: 255)
      end
    end

    rule(:geocode).each do
      next if geocode_target_area_validator.valid?(value)

      key.failure("must include contiguous administrative levels starting at level 1")
    end
  end
end
