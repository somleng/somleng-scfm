module ConditionalSerialization
  extend ActiveSupport::Concern

  class_methods do
    def conditionally_serialize(*args)
      serialize(*args) if !database_adapter_helper.adapter_postgresql?
    end

    def _accessors_module
      @_accessors_module ||= begin
        mod = Module.new
        include mod
        mod
      end
    end
  end
end
