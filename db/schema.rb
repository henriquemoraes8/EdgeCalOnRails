# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150217043729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "subscriptions_id"
    t.integer  "subscribers_id"
    t.integer  "repetition_scheme_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "creator_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "memberships_id"
    t.integer  "members_id"
    t.integer  "owner_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "member_of_group_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "repetition_schemes", force: :cascade do |t|
    t.integer  "weekdays",   default: 0
    t.integer  "month_day"
    t.integer  "year_day"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "subscriber_id"
    t.integer  "subscribed_event_id"
    t.boolean  "has_email_notification"
    t.integer  "visibility",                   default: 0
    t.integer  "email_notification_time_unit", default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.integer  "created_events_id"
    t.integer  "subscriptions_id"
    t.integer  "subscribed_events_id"
    t.integer  "memeberships_id"
    t.integer  "member_of_group_id"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
