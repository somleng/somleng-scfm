require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    access_tokens: Field::HasMany,
    call_flow_logic: Field::String,
    callouts: Field::HasMany,
    contacts: Field::HasMany,
    metadata: Field::JSON.with_options(searchable: false),
    settings: Field::JSON.with_options(searchable: false),
    phone_calls: Field::HasMany,
    platform_provider_name: Field::String,
    permissions: Field::String,
    somleng_account_sid: Field::String,
    somleng_api_base_url: Field::String,
    somleng_api_host: Field::String,
    twilio_account_sid: Field::String,
    users: Field::HasMany,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    metadata
    call_flow_logic
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    call_flow_logic
    callouts
    contacts
    metadata
    permissions
    phone_calls
    platform_provider_name
    settings
    somleng_account_sid
    somleng_api_base_url
    somleng_api_host
    twilio_account_sid
    users
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
