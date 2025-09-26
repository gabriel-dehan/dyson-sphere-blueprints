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

ActiveRecord::Schema.define(version: 2025_05_21_131518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blueprint_mecha_colors", force: :cascade do |t|
    t.bigint "blueprint_id"
    t.bigint "color_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blueprint_id"], name: "index_blueprint_mecha_colors_on_blueprint_id"
    t.index ["color_id"], name: "index_blueprint_mecha_colors_on_color_id"
  end

  create_table "blueprint_usage_metrics", force: :cascade do |t|
    t.bigint "blueprint_id"
    t.bigint "user_id"
    t.integer "count", default: 0, null: false
    t.datetime "last_used_at", default: "2025-05-21 10:52:53"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blueprint_id"], name: "index_blueprint_usage_metrics_on_blueprint_id"
    t.index ["user_id"], name: "index_blueprint_usage_metrics_on_user_id"
  end

  create_table "blueprints", force: :cascade do |t|
    t.string "title", null: false
    t.text "encoded_blueprint"
    t.bigint "collection_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.bigint "mod_id"
    t.string "mod_version", null: false
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.json "summary"
    t.text "cover_picture_data"
    t.string "type", null: false
    t.text "blueprint_file_data"
    t.integer "usage_count", default: 0
    t.index "((summary ->> 'total_structures'::text))", name: "index_blueprints_on_summary_total_structures"
    t.index ["cached_votes_total"], name: "index_blueprints_on_cached_votes_total"
    t.index ["collection_id"], name: "index_blueprints_on_collection_id"
    t.index ["created_at"], name: "index_blueprints_on_created_at", order: :desc
    t.index ["mod_id"], name: "index_blueprints_on_mod_id"
    t.index ["mod_version"], name: "index_blueprints_on_mod_version"
    t.index ["slug"], name: "index_blueprints_on_slug", unique: true
    t.index ["type"], name: "index_blueprints_on_type"
    t.index ["usage_count"], name: "index_blueprints_on_usage_count"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name", null: false
    t.integer "type", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.string "category"
    t.index ["slug"], name: "index_collections_on_slug", unique: true
    t.index ["type"], name: "index_collections_on_type"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "colors", force: :cascade do |t|
    t.string "name", null: false
    t.integer "r", null: false
    t.integer "g", null: false
    t.integer "b", null: false
    t.float "h", null: false
    t.float "s", null: false
    t.float "l", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.bigint "blueprint_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
    t.datetime "deleted_at"
    t.index ["blueprint_id"], name: "index_comments_on_blueprint_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "likes_count", default: 0
    t.string "likable_type", null: false
    t.bigint "likable_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["likable_type", "likable_id", "user_id"], name: "index_likes_on_likable_type_and_likable_id_and_user_id", unique: true
    t.index ["likable_type", "likable_id"], name: "index_likes_on_likable"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "mods", force: :cascade do |t|
    t.string "name", null: false
    t.string "author", null: false
    t.string "uuid4", null: false
    t.json "versions"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_mods_on_name"
  end

  create_table "pictures", force: :cascade do |t|
    t.bigint "blueprint_id"
    t.text "picture_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blueprint_id"], name: "index_pictures_on_blueprint_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.string "category"
    t.index "lower((name)::text)", name: "index_tags_on_LOWER_name"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["name"], name: "index_tags_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "role", default: "member", null: false
    t.string "provider"
    t.string "uid"
    t.string "discord_avatar_url"
    t.string "token"
    t.datetime "token_expiry"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.string "votable_type"
    t.bigint "votable_id"
    t.string "voter_type"
    t.bigint "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter_type_and_voter_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blueprints", "collections"
  add_foreign_key "blueprints", "mods"
  add_foreign_key "collections", "users"
  add_foreign_key "comments", "blueprints"
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "pictures", "blueprints"
  add_foreign_key "taggings", "tags"
end
