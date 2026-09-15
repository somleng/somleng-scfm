module FieldDefinitions
  class BroadcastFilter < Filter
    class GeocodeTargetAreasFieldQuery < FieldQuery
      def to_arel(operator:, value:, **options)
        query_params = {
          administrative_level: options.fetch(:administrative_level),
          geocode: value
        }

        scope = case operator.to_sym
        when :eq
          Broadcast.geocode_target_areas_equal(**query_params)
        when :contains
          Broadcast.geocode_target_areas_contain(**query_params)
        end

        Broadcast.arel_table[:id].in(scope.select(:id).arel)
      end
    end

    def self.geocode_target_areas
      new(
        schema: FilterSchema::ArrayType.define(operators: [ :eq, :contains ]),
        query: GeocodeTargetAreasFieldQuery.new
      )
    end
  end
end
