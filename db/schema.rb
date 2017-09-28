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

ActiveRecord::Schema.define(version: 20170926070754) do

  create_table "callouts", force: :cascade do |t|
    t.text "metadata", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phone_calls", force: :cascade do |t|
    t.integer "phone_number_id", null: false
    t.string "status", null: false
    t.string "remote_call_id"
    t.string "remote_status"
    t.text "remote_error_message"
    t.integer "lock_version"
    t.text "metadata", default: "{}", null: false
    t.text "remote_response", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number_id"], name: "index_phone_calls_on_phone_number_id"
    t.index ["remote_call_id"], name: "index_phone_calls_on_remote_call_id", unique: true
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.integer "callout_id", null: false
    t.string "msisdn", null: false
    t.text "metadata", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["callout_id", "msisdn"], name: "index_phone_numbers_on_callout_id_and_msisdn", unique: true
    t.index ["callout_id"], name: "index_phone_numbers_on_callout_id"
  end

end
