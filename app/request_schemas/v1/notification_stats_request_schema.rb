module V1
  class NotificationStatsRequestSchema < ApplicationRequestSchema
    option :output_serializer, default: -> {
      StatsRequestSchemaOutputSerializer.new(
        filter_class: NotificationFilter,
        field_definitions: FieldDefinitions::NotificationFields
      )
    }

    GROUPS = [
      "status",
      *BeneficiaryStatsRequestSchema::GROUPS.map { |f| "beneficiary.#{f}" }
    ].freeze

    params do
      optional(:filter).schema(NotificationFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: NotificationFilter)

    def output
      output_serializer.serialize(super)
    end
  end
end
