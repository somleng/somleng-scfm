module ValidateSchemaController
  extend ActiveSupport::Concern

  included do
    class_attribute :request_schema
  end

  private

  def build_resource_from_params
    @resource = build_resource_association_chain.new
  end

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
    schema = request_schema.new(
      input_params: permitted_schema_params,
      options: {
        resource: resource,
        account: current_account
      }
    )

    if schema.success?
      yield(schema.output)
    else
      build_errors(schema)
    end
  end

  def build_errors(schema)
    schema.errors.each do |message|
      resource.errors.add(message.path.join("."), message.text)
    end

    resource
  end

  def permitted_schema_params
    permitted_params.to_h
  end
end
