module SchemaRules
  class ApplicationSchemaRules
    attr_reader :context

    def initialize(context)
      @context = context
    end

    delegate :account, :values, :resource, :key, to: :context
  end
end
