# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_10_012554) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "dashboard_broadcast_beneficiary_filter_whitelist", default: [], null: false, array: true
    t.integer "delivery_attempt_queue_limit", null: false
    t.citext "iso_country_code", null: false
    t.integer "max_delivery_attempts_for_notification", null: false
    t.string "name", null: false
    t.string "notification_phone_number"
    t.citext "somleng_account_sid"
    t.string "somleng_auth_token"
    t.citext "subdomain", null: false
    t.string "supported_channels", default: [], null: false, array: true
    t.datetime "updated_at", precision: nil, null: false
    t.index ["somleng_account_sid"], name: "index_accounts_on_somleng_account_sid", unique: true
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.date "date_of_birth"
    t.string "disability_status"
    t.string "gender"
    t.citext "iso_country_code", null: false
    t.citext "iso_language_code"
    t.jsonb "metadata", default: {}, null: false
    t.string "phone_number", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "date_of_birth"], name: "index_beneficiaries_on_account_id_and_date_of_birth"
    t.index ["account_id", "disability_status"], name: "index_beneficiaries_on_account_id_and_disability_status"
    t.index ["account_id", "gender"], name: "index_beneficiaries_on_account_id_and_gender"
    t.index ["account_id", "iso_country_code"], name: "index_beneficiaries_on_account_id_and_iso_country_code"
    t.index ["account_id", "iso_language_code"], name: "index_beneficiaries_on_account_id_and_iso_language_code"
    t.index ["account_id", "phone_number"], name: "index_beneficiaries_on_account_id_and_phone_number", unique: true
    t.index ["account_id", "status"], name: "index_beneficiaries_on_account_id_and_status", where: "((status)::text = 'active'::text)"
    t.index ["account_id"], name: "index_beneficiaries_on_account_id"
    t.index ["created_at"], name: "index_beneficiaries_on_created_at"
    t.index ["updated_at"], name: "index_beneficiaries_on_updated_at"
  end

  create_table "beneficiary_addresses", force: :cascade do |t|
    t.citext "administrative_division_level_2_code"
    t.citext "administrative_division_level_2_name"
    t.citext "administrative_division_level_3_code"
    t.citext "administrative_division_level_3_name"
    t.citext "administrative_division_level_4_code"
    t.citext "administrative_division_level_4_name"
    t.citext "administrative_division_level_5_code"
    t.citext "administrative_division_level_5_name"
    t.bigint "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.citext "iso_region_code", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id", "iso_region_code", "administrative_division_level_2_code", "administrative_division_level_3_code", "administrative_division_level_4_code", "administrative_division_level_5_code"], name: "idx_on_beneficiary_id_iso_region_code_administrativ_e40dc43f80"
    t.index ["beneficiary_id", "iso_region_code", "administrative_division_level_2_name", "administrative_division_level_3_name", "administrative_division_level_4_name", "administrative_division_level_5_name"], name: "idx_on_beneficiary_id_iso_region_code_administrativ_07df769d41"
    t.index ["beneficiary_id"], name: "index_beneficiary_addresses_on_beneficiary_id"
  end

  create_table "beneficiary_group_memberships", force: :cascade do |t|
    t.bigint "beneficiary_group_id", null: false
    t.bigint "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id", "beneficiary_group_id"], name: "idx_on_beneficiary_id_beneficiary_group_id_ec5ce5d8dd", unique: true
  end

  create_table "beneficiary_groups", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_beneficiary_groups_on_account_id"
  end

  create_table "broadcast_beneficiary_groups", force: :cascade do |t|
    t.bigint "beneficiary_group_id", null: false
    t.bigint "broadcast_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broadcast_id", "beneficiary_group_id"], name: "idx_on_broadcast_id_beneficiary_group_id_2859ae2689", unique: true
  end

  create_table "broadcasts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "audio_url"
    t.jsonb "beneficiary_filter", default: {}, null: false
    t.string "channel", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "created_by_id"
    t.string "created_via", null: false
    t.string "error_code"
    t.text "message"
    t.jsonb "metadata", default: {}, null: false
    t.citext "name"
    t.datetime "started_at"
    t.bigint "started_by_id"
    t.string "status", null: false
    t.bigint "stopped_by_id"
    t.jsonb "target_areas", default: {}, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "updated_by_id"
    t.index ["account_id", "name"], name: "index_broadcasts_on_account_id_and_name"
    t.index ["account_id"], name: "index_broadcasts_on_account_id"
    t.index ["channel"], name: "index_broadcasts_on_channel"
    t.index ["created_by_id"], name: "index_broadcasts_on_created_by_id"
    t.index ["created_via"], name: "index_broadcasts_on_created_via"
    t.index ["started_by_id"], name: "index_broadcasts_on_started_by_id"
    t.index ["status"], name: "index_broadcasts_on_status"
    t.index ["stopped_by_id"], name: "index_broadcasts_on_stopped_by_id"
    t.index ["updated_by_id"], name: "index_broadcasts_on_updated_by_id"
  end

  create_table "delivery_attempts", force: :cascade do |t|
    t.bigint "beneficiary_id"
    t.bigint "broadcast_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: nil, null: false
    t.string "error_code"
    t.datetime "initiated_at", precision: nil
    t.integer "lock_version", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "notification_id", null: false
    t.string "phone_number", null: false
    t.datetime "queued_at"
    t.string "status", null: false
    t.datetime "status_update_queued_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["beneficiary_id"], name: "index_delivery_attempts_on_beneficiary_id"
    t.index ["broadcast_id", "status"], name: "index_delivery_attempts_on_broadcast_id_and_status"
    t.index ["broadcast_id"], name: "index_delivery_attempts_on_broadcast_id"
    t.index ["created_at"], name: "index_delivery_attempts_on_created_at"
    t.index ["error_code", "beneficiary_id"], name: "index_delivery_attempts_on_error_code_and_beneficiary_id", where: "((error_code)::text = 'phone_number_unreachable'::text)"
    t.index ["id", "lock_version"], name: "index_delivery_attempts_on_id_and_lock_version"
    t.index ["initiated_at"], name: "index_delivery_attempts_on_initiated_at"
    t.index ["notification_id"], name: "index_delivery_attempts_on_notification_id"
    t.index ["phone_number"], name: "index_delivery_attempts_on_phone_number"
    t.index ["status"], name: "index_delivery_attempts_on_status"
    t.index ["status_update_queued_at"], name: "index_delivery_attempts_on_status_update_queued_at"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_events_on_account_id"
    t.index ["type"], name: "index_events_on_type"
  end

  create_table "exports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "filter_params", default: {}, null: false
    t.string "name", null: false
    t.integer "progress_percentage", default: 0, null: false
    t.string "resource_type", null: false
    t.jsonb "scoped_to", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_exports_on_account_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "geocode_target_areas", force: :cascade do |t|
    t.integer "administrative_level", null: false
    t.bigint "broadcast_id", null: false
    t.datetime "created_at", null: false
    t.string "geocode", null: false
    t.string "path", null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["administrative_level", "geocode"], name: "index_geocode_target_areas_on_administrative_level_and_geocode"
    t.index ["broadcast_id", "path"], name: "index_geocode_target_areas_on_broadcast_id_and_path", unique: true
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "error_code"
    t.string "error_message"
    t.string "resource_type", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_imports_on_account_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "beneficiary_id"
    t.bigint "broadcast_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: nil, null: false
    t.integer "delivery_attempts_count", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "phone_number", null: false
    t.integer "priority", default: 0, null: false
    t.string "status", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["beneficiary_id"], name: "index_notifications_on_beneficiary_id"
    t.index ["broadcast_id", "beneficiary_id"], name: "index_notifications_on_broadcast_id_and_beneficiary_id", unique: true
    t.index ["broadcast_id", "id"], name: "index_notifications_on_broadcast_id_and_id", order: { id: :desc }
    t.index ["broadcast_id", "phone_number"], name: "index_notifications_on_broadcast_id_and_phone_number", unique: true
    t.index ["broadcast_id"], name: "index_notifications_on_broadcast_id"
    t.index ["completed_at"], name: "index_notifications_on_completed_at"
    t.index ["priority"], name: "index_notifications_on_priority"
    t.index ["status", "created_at", "broadcast_id"], name: "index_notifications_on_status_and_created_at_and_broadcast_id"
    t.index ["status"], name: "index_notifications_on_status"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "application_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "permissions", default: 0, null: false
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.string "owner_type", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["owner_id"], name: "index_oauth_applications_on_owner_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.integer "consumed_timestep"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.string "language", default: "en", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name", null: false
    t.boolean "otp_required_for_login", default: false, null: false
    t.string "otp_secret"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "role", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.bigint "oauth_application_id", null: false
    t.string "signing_secret", null: false
    t.string "subscriptions", null: false, array: true
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["oauth_application_id"], name: "index_webhook_endpoints_on_oauth_application_id"
  end

  create_table "webhook_request_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.boolean "failed", null: false
    t.string "http_status_code", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.bigint "webhook_endpoint_id", null: false
    t.index ["event_id"], name: "index_webhook_request_logs_on_event_id"
    t.index ["webhook_endpoint_id"], name: "index_webhook_request_logs_on_webhook_endpoint_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "beneficiaries", "accounts"
  add_foreign_key "beneficiary_addresses", "beneficiaries", on_delete: :cascade
  add_foreign_key "beneficiary_group_memberships", "beneficiaries", on_delete: :cascade
  add_foreign_key "beneficiary_group_memberships", "beneficiary_groups", on_delete: :cascade
  add_foreign_key "beneficiary_groups", "accounts", on_delete: :cascade
  add_foreign_key "broadcast_beneficiary_groups", "beneficiary_groups", on_delete: :cascade
  add_foreign_key "broadcast_beneficiary_groups", "broadcasts", on_delete: :cascade
  add_foreign_key "broadcasts", "accounts"
  add_foreign_key "broadcasts", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "broadcasts", "users", column: "started_by_id", on_delete: :nullify
  add_foreign_key "broadcasts", "users", column: "stopped_by_id", on_delete: :nullify
  add_foreign_key "broadcasts", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "delivery_attempts", "beneficiaries", on_delete: :nullify
  add_foreign_key "delivery_attempts", "broadcasts"
  add_foreign_key "delivery_attempts", "notifications"
  add_foreign_key "events", "accounts", on_delete: :cascade
  add_foreign_key "exports", "accounts", on_delete: :cascade
  add_foreign_key "exports", "users", on_delete: :cascade
  add_foreign_key "geocode_target_areas", "broadcasts", on_delete: :cascade
  add_foreign_key "imports", "accounts", on_delete: :cascade
  add_foreign_key "imports", "users", on_delete: :cascade
  add_foreign_key "notifications", "beneficiaries", on_delete: :nullify
  add_foreign_key "notifications", "broadcasts"
  add_foreign_key "oauth_access_grants", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "accounts", column: "owner_id"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "users", column: "invited_by_id", on_delete: :nullify
  add_foreign_key "webhook_endpoints", "oauth_applications", on_delete: :cascade
  add_foreign_key "webhook_request_logs", "events", on_delete: :cascade
  add_foreign_key "webhook_request_logs", "webhook_endpoints", on_delete: :cascade
end
