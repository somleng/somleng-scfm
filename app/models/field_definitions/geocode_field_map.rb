module FieldDefinitions
  class GeocodeFieldMap
    class << self
      def to_administrative_level(name)
        map.fetch(:administrative_levels).fetch(name.to_sym)
      end

      def to_name(level)
        map.fetch(:field_names).fetch(level)
      end

      def field_names
        map.fetch(:administrative_levels).keys
      end

      private

      def map
        @map ||= begin
          field_definitions.each_with_object(Hash.new { |h, key| h[key] = {} }) do |field, result|
            administrative_level = field.metadata.fetch(:administrative_level)

            result[:administrative_levels][field.name.to_sym] = administrative_level
            result[:field_names][administrative_level] = field.name
          end
        end
      end

      def field_definitions
        BroadcastFields.select { it.metadata.key?(:administrative_level) }
      end
    end
  end
end
