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

ActiveRecord::Schema.define(version: 20150416040722) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "repetition_scheme_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "creator_id"
    t.integer  "event_type",           default: 0
    t.integer  "to_do_id"
    t.integer  "request_map_id"
    t.integer  "respective_slot_id"
  end

  create_table "fullcalendar_engine_event_series", force: :cascade do |t|
    t.integer  "frequency",  default: 1
    t.string   "period",     default: "monthly"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fullcalendar_engine_events", force: :cascade do |t|
    t.string   "title"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",         default: false
    t.text     "description"
    t.integer  "event_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fullcalendar_engine_events", ["event_series_id"], name: "index_fullcalendar_engine_events_on_event_series_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "owner_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "group_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.integer  "recurrence",         default: 0
    t.datetime "next_reminder_time"
    t.integer  "to_do_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "job_id"
    t.integer  "subscription_id"
  end

  create_table "repetition_schemes", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "min_time_slot_duration"
    t.integer  "max_time_slot_duration"
    t.integer  "status",                 default: 0
    t.integer  "creator_id"
  end

  create_table "repetition_schemes_users", id: false, force: :cascade do |t|
    t.integer "repetition_scheme_id"
    t.integer "user_id"
  end

  create_table "request_maps", force: :cascade do |t|
    t.integer  "event_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.integer  "request_map_id",             null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.integer  "status",         default: 0
    t.string   "title"
    t.string   "description"
    t.datetime "start_time"
    t.datetime "end_time"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "subscriber_id"
    t.integer  "subscribed_event_id"
    t.boolean  "has_email_notification"
    t.integer  "visibility",                   default: 0
    t.integer  "email_notification_time_unit", default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "reminder_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id",      null: false
    t.datetime "start_time"
    t.integer  "duration"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "slot_event_id"
    t.integer  "preference"
  end

  create_table "to_dos", force: :cascade do |t|
    t.boolean  "done",                  default: false
    t.integer  "event_id"
    t.integer  "position",                              null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "recurrence",            default: 0
    t.string   "title",                                 null: false
    t.string   "description"
    t.integer  "creator_id",                            null: false
    t.datetime "next_reschedule"
    t.integer  "reminder_id"
    t.integer  "duration"
    t.datetime "expiration"
    t.integer  "job_id"
    t.integer  "escalation_prior",      default: 0
    t.integer  "escalation_recurrence", default: 0
    t.integer  "escalation_step"
    t.integer  "repetition_scheme_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
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

  create_table "visibilities", force: :cascade do |t|
    t.integer  "status",     null: false
    t.integer  "event_id",   null: false
    t.integer  "position",   null: false
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
