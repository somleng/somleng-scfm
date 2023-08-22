require "administrate/base_dashboard"

class ContactDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    callouts: Field::HasMany,
    metadata: Field::JSON.with_options(searchable: false),
    msisdn: Field::String,
    phone_calls: Field::HasMany,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    callouts
    metadata
    msisdn
    phone_calls
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
