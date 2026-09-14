class BeneficiaryFilterForm < FilterForm
  self.filter_class = BeneficiaryFilter

  class AddressFieldForm < FilterFieldForm; end

  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :gender, FormType.new(form: FilterFieldForm)
  attribute :disability_status, FormType.new(form: FilterFieldForm)
  attribute :date_of_birth, FormType.new(form: FilterFieldForm)
  attribute :iso_language_code, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)
  attribute :phone_number, FormType.new(form: FilterFieldForm)
  attribute :iso_country_code, FormType.new(form: FilterFieldForm)
  attribute :iso_region_code, FormType.new(form: FilterFieldForm)
  attribute :administrative_division_level_2_code, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_3_code, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_4_code, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_5_code, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_2_name, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_3_name, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_4_name, FormType.new(form: AddressFieldForm)
  attribute :administrative_division_level_5_name, FormType.new(form: AddressFieldForm)
end
