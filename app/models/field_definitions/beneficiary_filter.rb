module FieldDefinitions
  class BeneficiaryFilter < Filter
    def self.address(column_name)
      new(
        schema: FilterSchema::StringType.define,
        query: FieldQuery.new(
          arel_column: BeneficiaryAddress.arel_table[column_name],
          association: :addresses
        )
      )
    end
  end
end
