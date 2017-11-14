module ConditionalSerialization
  extend ActiveSupport::Concern

  module ClassMethods
    def conditionally_serialize(*args)
      serialize(*args) if !database_adapter_helper.adapter_postgresql?
    end

    def conditionally_store(*args)
      store(*args) if !database_adapter_helper.adapter_postgresql?
    end
  end
end
