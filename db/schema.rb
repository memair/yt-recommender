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

ActiveRecord::Schema.define(version: 2019_02_21_000034) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.string "yt_id", null: false
    t.string "title"
    t.string "description"
    t.boolean "ordered", default: false
    t.integer "max_age"
    t.datetime "last_extracted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_frequency", default: 4
    t.string "thumbnail_url"
  end

  create_table "preferences", force: :cascade do |t|
    t.integer "frequency"
    t.bigint "user_id"
    t.bigint "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_preferences_on_channel_id"
    t.index ["user_id", "channel_id"], name: "index_preferences_on_user_id_and_channel_id", unique: true
    t.index ["user_id"], name: "index_preferences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memair_access_token"
    t.datetime "last_recommended_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.string "yt_id", null: false
    t.datetime "published_at"
    t.string "title"
    t.string "description"
    t.integer "duration"
    t.jsonb "tags"
    t.bigint "channel_id"
    t.bigint "previous_video_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_videos_on_channel_id"
    t.index ["previous_video_id"], name: "index_videos_on_previous_video_id"
    t.index ["yt_id"], name: "index_videos_on_yt_id"
  end

  add_foreign_key "preferences", "channels"
  add_foreign_key "preferences", "users", on_delete: :cascade
  add_foreign_key "videos", "channels"
end
