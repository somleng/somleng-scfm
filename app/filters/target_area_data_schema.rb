module V1
  class TargetAreaSchema < JSONAPIRequestSchema
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
      levels = value.keys
              .map { FieldDefinitions::TargetAreaFields.find_by!(name: it).attributes.fetch(:administrative_level) }
              .sort

      next if levels == (1..levels.size).to_a

      key.failure("must include contiguous administrative levels starting at level 1")
    end
  end
end
