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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140309032643) do

  create_table "answers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.text     "body"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "solution"
    t.integer  "points_cache"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "privacy"
    t.string   "url"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "description"
    t.string   "logo_url"
    t.text     "welcome_message"
  end

  add_index "groups", ["url"], :name => "index_groups_on_url"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "role"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "invitation_email"
    t.string   "token"
    t.integer  "invited_by_user_id"
    t.boolean  "notifications_enabled", :default => true
  end

  add_index "memberships", ["user_id", "group_id"], :name => "index_group_users_on_user_id_and_group_id"

  create_table "questions", :force => true do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.text     "body"
    t.string   "url"
    t.integer  "group_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "answers_count", :default => 0
  end

  add_index "questions", ["url"], :name => "index_questions_on_url"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "auth_uid"
    t.string   "auth_provider"
    t.string   "ip_address"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "url"
    t.string   "avatar_url"
    t.text     "description"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["url"], :name => "index_users_on_url"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
