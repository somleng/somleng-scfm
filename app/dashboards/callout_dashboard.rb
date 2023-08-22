require "administrate/base_dashboard"

class CalloutDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    audio_file_attachment: Field::ActiveStorage,
    audio_url: Field::String,
    call_flow_logic: Field::String,
    contacts: Field::HasMany,
    created_by: Field::BelongsTo,
    metadata: Field::JSON.with_options(searchable: false),
    phone_calls: Field::HasMany,
    settings: Field::JSON.with_options(searchable: false),
    status: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    audio_file_attachment
    audio_url
    call_flow_logic
    contacts
    created_by
    metadata
    phone_calls
    settings
    status
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
