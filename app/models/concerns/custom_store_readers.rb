module CustomStoreReaders
  extend ActiveSupport::Concern

  private

  def read_custom_store_reader(store_attribute, key)
    store_attribute_value = public_send(store_attribute)
    if store_attribute_value.respond_to?(:with_indifferent_access)
      store_attribute_value.with_indifferent_access[key]
    end
  end

  class_methods do
    def hash_store_reader(*keys)
      _keys_for_stored_attribute(keys) do |store_attribute, key|
        _accessors_module.module_eval do
          define_method(key) do
            read_custom_store_reader(store_attribute, key) || {}
          end
        end
      end
    end

    def integer_store_reader(*keys)
      _keys_for_stored_attribute(keys) do |store_attribute, key|
        _accessors_module.module_eval do
          define_method(key) do
            raw = read_custom_store_reader(store_attribute, key)
            raw && raw.to_i
          end
        end
      end
    end

    def boolean_store_reader(*keys)
      _keys_for_stored_attribute(keys) do |store_attribute, key|
        _accessors_module.module_eval do
          define_method("#{key}?") do
            raw = read_custom_store_reader(store_attribute, key)
            ActiveRecord::Type::Boolean.new.cast(raw)
          end
        end
      end
    end

    def generic_store_reader(*keys)
      _keys_for_stored_attribute(keys) do |store_attribute, key|
        _accessors_module.module_eval do
          define_method(key) do
            read_custom_store_reader(store_attribute, key)
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

    def _keys_for_stored_attribute(keys, &block)
      stored_attributes.each do |store_attribute, attributes|
        (attributes & keys).each do |key|
          yield(store_attribute, key)
        end
      end
    end
  end
end
