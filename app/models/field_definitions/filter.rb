module FieldDefinitions
  Filter = Data.define(:schema, :query) do
    def initialize(schema:, **)
      super(schema:, query: FieldQuery.new, **)
    end

    def self.timestamp(**)
      new(
        schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime),
        **
      )
    end
  end
end
