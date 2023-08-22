require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    email: Field::String,
    invitation_sent_at: Field::LocalTime,
    invited_by: Field::BelongsTo,
    locale: Field::String,
    locked_at: Field::LocalTime,
    metadata: Field::JSON.with_options(searchable: false),
    sign_in_count: Field::Number,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    email
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    email
    invitation_sent_at
    invited_by
    locale
    locked_at
    metadata
    sign_in_count
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
