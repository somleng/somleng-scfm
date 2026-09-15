module V1
  class StatsRequestSchemaOutputSerializer
    attr_reader :filter_class, :field_definitions

    def initialize(filter_class:, field_definitions:)
      @filter_class = filter_class
      @field_definitions = field_definitions
    end

    def serialize(schema_output)
      result = schema_output.dup

      result[:filter_group] = if result[:filter].present?
        filter_class.new(input_params: result[:filter]).output
      else
        FilterGroup.new
      end

      result[:group_by] = result[:group_by].map do |group|
        field_definition = field_definitions.find_by!(path: group)

        GroupByField.new(
          name: field_definition.path,
          query: field_definition.filter.query
        )
      end

      result
    end
  end
end
