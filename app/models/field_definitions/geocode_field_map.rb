module FieldDefinitions
  class GeocodeFieldMap
    class << self
      def to_administrative_level(name)
        map.fetch(:administrative_levels).fetch(name.to_sym)
      end

      def to_name(level)
        map.fetch(:field_names).fetch(level)
      end

      def fields
        field_definitions.select { it.metadata.key?(:administrative_level) }
      end

      private

      def map
        @map ||= begin
          fields.each_with_object(Hash.new { |h, key| h[key] = {} }) do |field, result|
            administrative_level = field.metadata.fetch(:administrative_level)

            result[:administrative_levels][field.name.to_sym] = administrative_level
            result[:field_names][administrative_level] = field.name
          end
        end
      end

      def field_definitions
        BroadcastFields
      end
    end
  end
end
