module V1
  class EventStatsRequestSchema < ApplicationRequestSchema
    option :output_serializer, default: -> {
      StatsRequestSchemaOutputSerializer.new(
        filter_class: EventFilter,
        field_definitions: FieldDefinitions::EventFields
      )
    }

    GROUPS = [ "type" ].freeze

    params do
      optional(:filter).schema(EventFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: EventFilter)

    def output
      output_serializer.serialize(super)
    end
  end
end
