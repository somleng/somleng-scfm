module MetadataHelpers
  extend ActiveSupport::Concern
  include ConditionalSerialization
  include JsonQueryHelpers

  included do
    conditionally_serialize(:metadata, JSON)
  end

  def call_flow_logic
    metadata["call_flow_logic"]
  end

  module ClassMethods
    def metadata_has_value(key, value)
      json_has_value(key, value, :metadata)
    end

    def metadata_has_values(hash)
      json_has_values(hash, :metadata)
    end
  end
end
