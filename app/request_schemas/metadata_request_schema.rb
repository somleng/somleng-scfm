class MetadataRequestSchema < ApplicationRequestSchema
  METADATA_MERGE_MODES = %w[replace merge deep_merge].freeze

  params do
    optional(:metadata).filled(:hash)
    optional(:metadata_merge_mode).filled(:str?, included_in?: METADATA_MERGE_MODES)
  end
end
