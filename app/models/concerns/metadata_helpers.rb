module MetadataHelpers
  extend ActiveSupport::Concern
  include ConditionalSerialization
  include JsonQueryHelpers

  METADATA_MERGE_MODE_MERGE = :merge
  METADATA_MERGE_MODE_REPLACE = :replace
  METADATA_MERGE_MODE_DEEP_MERGE = :deep_merge
  DEFAULT_METADATA_MERGE_MODE = METADATA_MERGE_MODE_MERGE

  METADATA_MERGE_MODES = [
    METADATA_MERGE_MODE_MERGE,
    METADATA_MERGE_MODE_REPLACE,
    METADATA_MERGE_MODE_DEEP_MERGE
  ]

  included do
    attr_accessor :metadata_merge_mode

    conditionally_serialize(:metadata, JSON)
    validates :metadata,
              :json => true
  end

  def metadata=(value)
    merge_mode = metadata_merge_mode_or_default
    if !metadata.is_a?(Hash) || !value.is_a?(Hash) || merge_mode == METADATA_MERGE_MODE_REPLACE
      super
    else
      super(metadata.public_send(merge_mode, value))
    end
  end

  private

  def metadata_merge_mode_or_default
    metadata_merge_mode && METADATA_MERGE_MODES.include?(metadata_merge_mode.to_sym) ? metadata_merge_mode.to_sym : DEFAULT_METADATA_MERGE_MODE
  end
end
