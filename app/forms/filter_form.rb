class FilterForm < ApplicationForm
  class_attribute :filter_class

  def self.model_name
    ActiveModel::Name.new(self, nil, "Filter")
  end

  def blank?
    attributes.values.all?(&:blank?)
  end

  def apply(scope)
    FilterScope.new(
      scope:,
      filter_group: filter_class.new(input_params: normalized_filter_params).output
    ).apply
  end

  def normalized_filter_params
    FilterFormType.new(
      form: self.class,
      field_definitions: filter_class.field_collection
    ).serialize(self)
  end
end
