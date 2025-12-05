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

ActiveRecord::Schema[7.1].define(version: 2025_12_04_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

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

  create_table "outfit_items", force: :cascade do |t|
    t.bigint "outfit_id", null: false
    t.bigint "wardrobe_item_id", null: false
    t.float "position_x"
    t.float "position_y"
    t.float "scale"
    t.float "rotation"
    t.integer "z_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outfit_id"], name: "index_outfit_items_on_outfit_id"
    t.index ["wardrobe_item_id"], name: "index_outfit_items_on_wardrobe_item_id"
  end

  create_table "outfit_suggestions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "context", null: false
    t.jsonb "gemini_response"
    t.jsonb "validated_suggestions", default: []
    t.integer "suggestions_count", default: 0
    t.decimal "api_cost", precision: 10, scale: 4, default: "0.0"
    t.integer "response_time_ms"
    t.string "status", default: "pending"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_outfit_suggestions_on_status"
    t.index ["user_id", "created_at"], name: "index_outfit_suggestions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_outfit_suggestions_on_user_id"
  end

  create_table "outfits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.jsonb "metadata"
    t.datetime "last_worn_at"
    t.boolean "favorite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_outfits_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", default: "", null: false
    t.integer "ai_suggestions_today", default: 0
    t.date "ai_suggestions_reset_at"
    t.string "subscription_tier", default: "free"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

# Could not dump table "wardrobe_items" because of following StandardError
#   Unknown type 'vector(768)' for column 'embedding'

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "outfit_items", "outfits"
  add_foreign_key "outfit_items", "wardrobe_items"
  add_foreign_key "outfit_suggestions", "users"
  add_foreign_key "outfits", "users"
  add_foreign_key "wardrobe_items", "users"
end
