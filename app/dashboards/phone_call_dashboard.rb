require "administrate/base_dashboard"

class PhoneCallDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    call_flow_logic: Field::String,
    callout: Field::BelongsTo,
    contact: Field::BelongsTo,
    duration: Field::Number,
    metadata: Field::JSON.with_options(searchable: false),
    msisdn: Field::String,
    remote_call_id: Field::String,
    remote_direction: Field::String,
    remote_error_message: Field::Text,
    remote_queue_response: Field::JSON.with_options(searchable: false),
    remote_response: Field::JSON.with_options(searchable: false),
    remote_status: Field::String,
    remote_status_fetch_queued_at: Field::LocalTime,
    remotely_queued_at: Field::LocalTime,
    status: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    msisdn
    account
    call_flow_logic
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    call_flow_logic
    callout
    contact
    duration
    metadata
    msisdn
    remote_call_id
    remote_direction
    remote_error_message
    remote_queue_response
    remote_response
    remote_status
    remote_status_fetch_queued_at
    remotely_queued_at
    status
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
