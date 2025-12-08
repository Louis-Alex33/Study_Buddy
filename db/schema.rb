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

ActiveRecord::Schema[7.1].define(version: 2025_12_08_084629) do
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_lectures_on_category_id"
    t.index ["user_id"], name: "index_lectures_on_user_id"
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
    t.text "content"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lecture_id"], name: "index_quizzes_on_lecture_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
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
  add_foreign_key "flashcard_completions", "flashcards"
  add_foreign_key "flashcard_completions", "users"
  add_foreign_key "flashcards", "lectures"
  add_foreign_key "lectures", "categories"
  add_foreign_key "lectures", "users"
  add_foreign_key "messages", "lectures"
  add_foreign_key "messages", "users"
  add_foreign_key "notes", "lectures"
  add_foreign_key "notes", "users"
  add_foreign_key "quizzes", "lectures"
end
