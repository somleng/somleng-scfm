module CustomStoreReaders
  extend ActiveSupport::Concern

  class_methods do
    def hash_store_reader(*keys)
      _accessors_module.module_eval do
        keys.each do |key|
          define_method(key) do
            super() || {}
          end
        end
      end
    end

    def integer_store_reader(*keys)
      _accessors_module.module_eval do
        keys.each do |key|
          define_method(key) do
            raw = super()
            raw && raw.to_i
          end
        end
      end
    end

    def boolean_store_reader(*keys)
      _accessors_module.module_eval do
        keys.each do |key|
          define_method("#{key}?") do
            ActiveRecord::Type::Boolean.new.cast(public_send(key))
          end
        end
      end
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
