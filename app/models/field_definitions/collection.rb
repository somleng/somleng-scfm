module FieldDefinitions
  class Collection
    include Enumerable

    attr_reader :collection

    delegate :each, to: :collection

    def initialize(collection)
      @collection = collection
    end

    def concat(other)
      self.class.new(collection.concat(other.collection))
    end

    def find_by!(attributes)
      collection.find(-> { raise ArgumentError, "Unable to find field with #{attributes}" }) do |field|
        attributes.all? { |key, value| value.to_s == field.to_h.dig(*Array(key).map(&:to_sym)).to_s }
      end
    end
  end
end
