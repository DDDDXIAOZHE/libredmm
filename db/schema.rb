# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_27_205956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "movies", force: :cascade do |t|
    t.string "actresses", array: true
    t.string "actress_types", array: true
    t.string "categories", array: true
    t.string "code"
    t.string "cover_image"
    t.string "description"
    t.string "directors", array: true
    t.string "genres", array: true
    t.string "label"
    t.string "maker"
    t.string "movie_length"
    t.string "page"
    t.string "sample_images", array: true
    t.string "series"
    t.string "tags", array: true
    t.string "thumbnail_image"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "release_date"
  end

  create_table "resources", force: :cascade do |t|
    t.bigint "movie_id"
    t.string "download_uri"
    t.string "source_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_obsolete", default: false
    t.string "tags", default: [], array: true
    t.index ["movie_id"], name: "index_resources_on_movie_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.boolean "is_admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "movie_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_votes_on_movie_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "resources", "movies"
  add_foreign_key "votes", "movies"
  add_foreign_key "votes", "users"
end
