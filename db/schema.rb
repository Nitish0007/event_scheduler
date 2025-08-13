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

ActiveRecord::Schema[7.1].define(version: 2025_08_10_062626) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "status", default: 0
    t.index ["ticket_id"], name: "index_bookings_on_ticket_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "event_title", null: false
    t.string "event_venue", null: false
    t.datetime "event_date", null: false
    t.bigint "tickets_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "fee", precision: 10, scale: 2, default: "0.0"
    t.string "currency", default: "usd"
    t.integer "status", default: 0
    t.integer "payment_method", default: 0
    t.string "reference_number", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_charge_id"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["reference_number"], name: "index_payments_on_reference_number", unique: true
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "ticket_type"
    t.bigint "event_id", null: false
    t.decimal "price_per_ticket", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "tickets_count", default: 0
    t.integer "booked_ticket_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "available_count", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "company"
    t.string "address"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "tickets"
  add_foreign_key "bookings", "users"
  add_foreign_key "events", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "users"
end
