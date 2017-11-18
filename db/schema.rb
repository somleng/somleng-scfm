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

ActiveRecord::Schema.define(version: 20171101092942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batch_operations", force: :cascade do |t|
    t.bigint "callout_id"
    t.jsonb "parameters", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "contacts", force: :cascade do |t|
    t.string "msisdn", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["msisdn"], name: "index_contacts_on_msisdn", unique: true
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

  add_foreign_key "batch_operations", "callouts"
  add_foreign_key "callout_participations", "batch_operations", column: "callout_population_id"
  add_foreign_key "callout_participations", "callouts"
  add_foreign_key "callout_participations", "contacts"
  add_foreign_key "phone_calls", "batch_operations", column: "create_batch_operation_id"
  add_foreign_key "phone_calls", "batch_operations", column: "queue_batch_operation_id"
  add_foreign_key "phone_calls", "batch_operations", column: "queue_remote_fetch_batch_operation_id"
  add_foreign_key "phone_calls", "callout_participations"
  add_foreign_key "phone_calls", "contacts"
  add_foreign_key "remote_phone_call_events", "phone_calls"
end
