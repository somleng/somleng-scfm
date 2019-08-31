module ValidateSchemaController
  extend ActiveSupport::Concern

  included do
    class_attribute :request_schema
  end

  private

  def create_resource
    @resource = validate_schema do |permitted_params|
      build_resource_association_chain.create!(permitted_params)
    end
  end

  def save_resource
    validate_schema do |permitted_params|
      resource.update!(permitted_params)
    end
  end

  def validate_schema(&_block)
    schema_validation_result = request_schema.with(
      resource: resource, account: current_account, action: action_name
    ).call(permitted_schema_params)

    if schema_validation_result.success?
      yield(schema_validation_result.output)
    else
      build_errors(schema_validation_result)
    end
  end

  def build_errors(schema_validation_result)
    schema_validation_result.errors.each do |field, messages|
      resource.errors.add(field, messages.first)
    end

    resource
  end

  def permitted_schema_params
    permitted_params.to_h
  end
end
