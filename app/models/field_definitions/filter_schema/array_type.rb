module FieldDefinitions
  module FilterSchema
    class ArrayType < Base
      def self.define(type: Dry.Types()::String, **options)
        schema = Dry::Schema.Params do
          schema_options = {}
          schema_options[:included_in?] = Array(options[:included_in]) if options.key?(:included_in)
          options.fetch(:operators, [ :eq, :contains ]).each do |operator|
            optional(operator).filled(type | Types::Array.of(type), **schema_options)
          end
        end

        new(
          schema_definition: schema,
          value_type: type,
          **options
        )
      end

      def options_for_select
        Array(options[:included_in]).map { [ it.text, it ] }
      end
    end
  end
end
