module KeyValueFieldsFor
  extend ActiveSupport::Concern

  class_methods do
    def accepts_nested_key_value_fields_for(attribute_name)
      mod = Module.new
      include mod
      mod.module_eval do
        define_method("#{attribute_name}_fields") do
          instance_variable_get(
            "@#{attribute_name}_fields"
          ) || instance_variable_set(
            "@#{attribute_name}_fields",
            key_value_fields_builder.from_nested_hash(send(attribute_name))
          )
        end

        define_method("build_#{attribute_name}_field") do
          new_key_value = KeyValueField.new
          send(:"#{attribute_name}_fields").push(new_key_value)
          new_key_value
        end

        define_method("#{attribute_name}_fields_attributes=") do |attributes|
          instance_variable_set(
            "@#{attribute_name}_fields",
            key_value_fields_builder.from_attributes(attributes)
          )

          send(
            :"#{attribute_name}=",
            key_value_fields_builder.to_h(send(:"#{attribute_name}_fields"))
          )
        end
      end
    end
  end

  private

  def key_value_fields_builder
    @key_value_fields_builder ||= KeyValueFieldsBuilder.new
  end
end
