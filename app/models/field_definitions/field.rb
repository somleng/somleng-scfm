module FieldDefinitions
  Field = Data.define(:name, :prefix, :path, :filter, :description, :read_only, :required, :example, :metadata) do
    def initialize(**attributes)
      prefix = attributes.fetch(:prefix).to_s.inquiry if attributes.key?(:prefix)

      super(
        read_only: false,
        required: false,
        description: nil,
        example: nil,
        metadata: {},
        **attributes,
        prefix:,
        path: [ prefix, attributes[:name] ].compact.join(".")
      )
    end

    def read_only?
      read_only
    end

    def required?
      required
    end
  end
end
