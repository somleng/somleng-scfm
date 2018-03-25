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
    attr_accessor :metadata_merge_mode, :metadata_forms

    conditionally_serialize(:metadata, JSON)
    validates :metadata,
              :json => true
    validate :valid_metadata_forms, on: :dashboard

    def metadata_forms
      @metadata_forms ||= unnest_metadata
    end

    def metadata_forms_attributes=(attributes)
      @metadata_forms = []

      attributes.each do |i, metadata_forms_params|
        metadata_form = MetadataForm.new(metadata_forms_params)
        @metadata_forms.push(metadata_form)
      end

      assign_metadata
    end
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

  def valid_metadata_forms
    if metadata_forms.map(&:valid?).include?(false)
      errors.add(:base, 'invalid metadata')
    end
  end

  def assign_metadata
    new_metadata = tranform_metadata_forms_to_hash
    metadata.public_send(:replace, new_metadata)
  end

  def tranform_metadata_forms_to_hash
    metadata_forms.reject{ |m| !m.valid? }
                  .map(&:to_json).reject(&:blank?)
                  .reduce(Hash.new, :deep_merge)
  end

  def unnest_metadata
    return [MetadataForm.new] if metadata.blank?
    MetadataForm.unnest(metadata).map{|k, v| MetadataForm.new(attr_key: k, attr_val: v) }
  end

  def metadata_merge_mode_or_default
    metadata_merge_mode && METADATA_MERGE_MODES.include?(metadata_merge_mode.to_sym) ? metadata_merge_mode.to_sym : DEFAULT_METADATA_MERGE_MODE
  end
end
