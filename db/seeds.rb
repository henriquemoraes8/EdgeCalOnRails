# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
	name: 'wes1',
	email: 'wes.koorbusch@gmail.com',
	password: 'munchthatbox',
	password_confirmation: 'munchthatbox'
)

User.create(
	name: 'wes2',
	email: 'wes.koorbusch@hotmail.com',
	password: 'munchthatbox',
	password_confirmation: 'munchthatbox'
)

User.create(
	name: 'wes3',
	email: 'wes.koorbusch@duke.edu',
	password: 'munchthatbox',
	password_confirmation: 'munchthatbox'
)

User.create(
	name: 'bolze1',
	email: 'hockeybolze@yahoo.com',
	password: 'munchthatbox',
	password_confirmation: 'munchthatbox'
)

User.create(
	name: 'jeff1',
	email: 'jeffday1113@gmail.com',
	password: 'munchthatbox',
	password_confirmation: 'munchthatbox'
)

#  create_table "users", force: :cascade do |t|
#    t.string   "username"
#    t.string   "email",                  default: "", null: false
#    t.string   "encrypted_password",     default: "", null: false
#    t.string   "reset_password_token"
#    t.datetime "reset_password_sent_at"
#    t.datetime "remember_created_at"
#    t.integer  "sign_in_count",          default: 0,  null: false
#    t.datetime "current_sign_in_at"
#    t.datetime "last_sign_in_at"
#    t.inet     "current_sign_in_ip"
#    t.inet     "last_sign_in_ip"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.string   "name"
#  end