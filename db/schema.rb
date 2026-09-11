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

ActiveRecord::Schema[8.1].define(version: 2026_09_10_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "documents", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.string "file_url"
    t.text "instructions"
    t.text "internal_note"
    t.string "kind", null: false
    t.integer "mortgage_project_id", null: false
    t.integer "mortgagor_id"
    t.datetime "rejected_at"
    t.string "rejection_reason"
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "status", default: "pending", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["mortgage_project_id"], name: "index_documents_on_mortgage_project_id"
    t.index ["mortgagor_id"], name: "index_documents_on_mortgagor_id"
  end

  create_table "mortgage_projects", force: :cascade do |t|
    t.string "advisor_name"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.string "reference", null: false
    t.string "status", default: "in_progress", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mortgagors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "employment_status"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "main", default: false, null: false
    t.integer "mortgage_project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mortgage_project_id"], name: "index_mortgagors_on_mortgage_project_id"
  end

  add_foreign_key "documents", "mortgage_projects"
  add_foreign_key "documents", "mortgagors"
  add_foreign_key "mortgagors", "mortgage_projects"
end
