module ConditionalSerialization
  extend ActiveSupport::Concern

  module ClassMethods
    def conditionally_serialize(*args)
      serialize(*args) if ActiveRecord::Base.connection.adapter_name.downcase != "postgresql"
    end
  end
end
