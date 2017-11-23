module MetadataHelpers
  extend ActiveSupport::Concern
  include ConditionalSerialization
  include JsonQueryHelpers

  included do
    conditionally_serialize(:metadata, JSON)
    validates :metadata,
              :json => true
  end

  class_methods do
    def metadata_has_value(key, value)
      json_has_value(key, value, :metadata)
    end

    def metadata_has_values(hash)
      json_has_values(hash, :metadata)
    end
  end
end
