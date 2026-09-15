class BeneficiaryFilterData
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :data, FilterDataType.new(field_definitions: FieldDefinitions::BeneficiaryFields)
end
