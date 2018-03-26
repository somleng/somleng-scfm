# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180325171833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "settings", default: {}, null: false
    t.string "twilio_account_sid"
    t.string "somleng_account_sid"
    t.integer "permissions", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["somleng_account_sid"], name: "index_accounts_on_somleng_account_sid", unique: true
    t.index ["twilio_account_sid"], name: "index_accounts_on_twilio_account_sid", unique: true
  end

  create_table "batch_operations", force: :cascade do |t|
    t.bigint "callout_id"
    t.jsonb "parameters", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_batch_operations_on_account_id"
    t.index ["callout_id"], name: "index_batch_operations_on_callout_id"
  end

  create_table "callout_participations", force: :cascade do |t|
    t.bigint "callout_id", null: false
    t.bigint "contact_id", null: false
    t.bigint "callout_population_id"
    t.string "msisdn", null: false
    t.string "call_flow_logic"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["callout_id", "contact_id"], name: "index_callout_participations_on_callout_id_and_contact_id", unique: true
    t.index ["callout_id", "msisdn"], name: "index_callout_participations_on_callout_id_and_msisdn", unique: true
    t.index ["callout_id"], name: "index_callout_participations_on_callout_id"
    t.index ["callout_population_id"], name: "index_callout_participations_on_callout_population_id"
    t.index ["contact_id"], name: "index_callout_participations_on_contact_id"
  end

  create_table "callouts", force: :cascade do |t|
    t.string "status", null: false
    t.string "call_flow_logic"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_callouts_on_account_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "msisdn", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id", "msisdn"], name: "index_contacts_on_account_id_and_msisdn", unique: true
    t.index ["account_id"], name: "index_contacts_on_account_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "created_by_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["created_by_id"], name: "index_oauth_access_tokens_on_created_by_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_oauth_applications_on_owner_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "phone_calls", force: :cascade do |t|
    t.bigint "callout_participation_id"
    t.bigint "contact_id", null: false
    t.bigint "create_batch_operation_id"
    t.bigint "queue_batch_operation_id"
    t.bigint "queue_remote_fetch_batch_operation_id"
    t.string "status", null: false
    t.string "msisdn", null: false
    t.string "remote_call_id"
    t.string "remote_status"
    t.string "remote_direction"
    t.text "remote_error_message"
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "remote_response", default: {}, null: false
    t.jsonb "remote_request_params", default: {}, null: false
    t.jsonb "remote_queue_response", default: {}, null: false
    t.string "call_flow_logic"
    t.datetime "remotely_queued_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["callout_participation_id"], name: "index_phone_calls_on_callout_participation_id"
    t.index ["contact_id"], name: "index_phone_calls_on_contact_id"
    t.index ["create_batch_operation_id"], name: "index_phone_calls_on_create_batch_operation_id"
    t.index ["queue_batch_operation_id"], name: "index_phone_calls_on_queue_batch_operation_id"
    t.index ["queue_remote_fetch_batch_operation_id"], name: "index_phone_calls_on_queue_remote_fetch_batch_operation_id"
    t.index ["remote_call_id"], name: "index_phone_calls_on_remote_call_id", unique: true
  end

  create_table "remote_phone_call_events", force: :cascade do |t|
    t.bigint "phone_call_id", null: false
    t.jsonb "details", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "remote_call_id", null: false
    t.string "remote_direction", null: false
    t.string "call_flow_logic", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_call_id"], name: "index_remote_phone_call_events_on_phone_call_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "roles", default: 1, null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "batch_operations", "accounts"
  add_foreign_key "batch_operations", "callouts"
  add_foreign_key "callout_participations", "batch_operations", column: "callout_population_id"
  add_foreign_key "callout_participations", "callouts"
  add_foreign_key "callout_participations", "contacts"
  add_foreign_key "callouts", "accounts"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "oauth_access_grants", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "created_by_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "accounts", column: "owner_id"
  add_foreign_key "phone_calls", "batch_operations", column: "create_batch_operation_id"
  add_foreign_key "phone_calls", "batch_operations", column: "queue_batch_operation_id"
  add_foreign_key "phone_calls", "batch_operations", column: "queue_remote_fetch_batch_operation_id"
  add_foreign_key "phone_calls", "callout_participations"
  add_foreign_key "phone_calls", "contacts"
  add_foreign_key "remote_phone_call_events", "phone_calls"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "users", column: "invited_by_id"
end
