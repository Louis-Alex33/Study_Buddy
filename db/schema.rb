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

ActiveRecord::Schema[7.1].define(version: 2025_12_02_141807) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.bigint "challenger_id", null: false
    t.bigint "opponent_id", null: false
    t.string "status", default: "pending", null: false
    t.bigint "category_id"
    t.bigint "winner_id"
    t.integer "score_challenger", default: 0
    t.integer "score_opponent", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_challenges_on_category_id"
    t.index ["challenger_id", "opponent_id"], name: "index_challenges_on_challenger_id_and_opponent_id"
    t.index ["challenger_id"], name: "index_challenges_on_challenger_id"
    t.index ["opponent_id"], name: "index_challenges_on_opponent_id"
    t.index ["status"], name: "index_challenges_on_status"
    t.index ["winner_id"], name: "index_challenges_on_winner_id"
  end

  create_table "flashcard_completions", force: :cascade do |t|
    t.string "status"
    t.bigint "user_id", null: false
    t.bigint "flashcard_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flashcard_id"], name: "index_flashcard_completions_on_flashcard_id"
    t.index ["user_id"], name: "index_flashcard_completions_on_user_id"
  end

  create_table "flashcards", force: :cascade do |t|
    t.text "content"
    t.text "expected_answer"
    t.bigint "lecture_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lecture_id"], name: "index_flashcards_on_lecture_id"
  end

  create_table "lectures", force: :cascade do |t|
    t.string "title"
    t.text "resume"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_lectures_on_category_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role"
    t.text "content"
    t.bigint "lecture_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["lecture_id"], name: "index_messages_on_lecture_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.bigint "lecture_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lecture_id"], name: "index_notes_on_lecture_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.bigint "lecture_id", null: false
    t.json "questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lecture_id"], name: "index_quizzes_on_lecture_id"
  end

  create_table "user_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "league"
    t.integer "level"
    t.integer "xp"
    t.integer "total_flashcards_completed"
    t.integer "total_notes_created"
    t.integer "streak_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "users"
  add_foreign_key "challenges", "categories"
  add_foreign_key "challenges", "users", column: "challenger_id"
  add_foreign_key "challenges", "users", column: "opponent_id"
  add_foreign_key "challenges", "users", column: "winner_id"
  add_foreign_key "flashcard_completions", "flashcards"
  add_foreign_key "flashcard_completions", "users"
  add_foreign_key "flashcards", "lectures"
  add_foreign_key "lectures", "categories"
  add_foreign_key "messages", "lectures"
  add_foreign_key "messages", "users"
  add_foreign_key "notes", "lectures"
  add_foreign_key "notes", "users"
  add_foreign_key "quizzes", "lectures"
  add_foreign_key "user_progresses", "users"
end
