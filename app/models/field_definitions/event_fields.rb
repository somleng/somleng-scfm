module FieldDefinitions
  EventFields = Collection.new(
    [
      Field.new(
        name: "type",
        filter: Filter.new(
          schema: FilterSchema::ListType.define(type: :string, options: Event.type.values)
        ),
        description: "The event type. Must be one of #{Event.type.values.map { "`#{it}`" }.join(", ")}."
      ),
      Field.new(
        name: "created_at",
        filter: Filter.timestamp,
        description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of the event."
      )
    ]
  )
end
