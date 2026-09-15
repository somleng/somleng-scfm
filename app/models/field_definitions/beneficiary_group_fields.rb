module FieldDefinitions
  BeneficiaryGroupFields = Collection.new(
    [
      Field.new(
        name: "name",
        filter: Filter.new(
          schema: FilterSchema::StringType.define
        ),
        description: "A friendly name for the group."
      )
    ]
  )
end
