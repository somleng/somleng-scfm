module Filter
  module Scope
    class HasPhoneCalls < Filter::Base
      def apply
        if ActiveRecord::Type::Boolean.new.cast(params.fetch(:has_phone_calls))
          association_chain.has_phone_calls
        else
          association_chain.no_phone_calls
        end
      end

      def apply?
        params.key?(:has_phone_calls)
      end
    end
  end
end
