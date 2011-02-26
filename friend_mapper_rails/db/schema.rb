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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110213171913) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "friend_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user_id"], :name => "user_id_ix"

  create_table "locations", :force => true do |t|
    t.float    "latitude"
    t.string   "name",       :limit => 100, :null => false
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country",    :limit => 100
    t.string   "state",      :limit => 40
    t.string   "city",       :limit => 100
  end

  add_index "locations", ["name"], :name => "name_ix", :unique => true

  create_table "users", :force => true do |t|
    t.string   "fb_id",         :limit => 40,  :null => false
    t.string   "first_name",    :limit => 100
    t.string   "last_name",     :limit => 100
    t.string   "location",      :limit => 100
    t.float    "latitude"
    t.float    "longitude"
    t.string   "fb_token",      :limit => 120
    t.datetime "token_expires"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
  end

  add_index "users", ["fb_id"], :name => "fb_id_ix", :unique => true
  add_index "users", ["location"], :name => "location_id_ix"

end
