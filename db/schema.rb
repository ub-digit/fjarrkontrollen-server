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

ActiveRecord::Schema[7.1].define(version: 2024_11_13_164205) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "token"
    t.datetime "token_expire", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "customer_types", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "name_sv"
    t.string "name_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "delivery_methods", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "name"
    t.string "public_name_sv"
    t.string "public_name_en"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "delivery_sources", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.string "name", limit: 255
    t.boolean "is_active"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "email_templates", id: :serial, force: :cascade do |t|
    t.text "subject_sv"
    t.text "subject_en"
    t.text "body_sv"
    t.text "body_en"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "label"
    t.boolean "disabled"
    t.integer "position"
  end

  create_table "managing_groups", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "name"
    t.string "email"
    t.string "sublocation"
    t.boolean "is_active"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "position"
  end

  create_table "note_types", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.text "message"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "subject"
    t.boolean "is_email"
    t.integer "note_type_id"
    t.datetime "deleted_at", precision: nil
    t.string "deleted_by"
    t.index ["order_id"], name: "index_notes_on_order_id"
  end

  create_table "order_types", id: :serial, force: :cascade do |t|
    t.string "name_sv", limit: 255
    t.string "name_en", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "label", limit: 255
    t.boolean "auth_required", default: true, null: false
    t.integer "default_managing_group_id"
    t.integer "position"
    t.index ["default_managing_group_id"], name: "index_order_types_on_default_managing_group_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "order_type_id"
    t.text "title"
    t.text "publication_year"
    t.text "volume"
    t.text "issue"
    t.text "pages"
    t.text "journal_title"
    t.text "issn_isbn"
    t.text "reference_information"
    t.boolean "photocopies_if_loan_not_possible"
    t.boolean "order_outside_scandinavia"
    t.boolean "email_confirmation"
    t.text "not_valid_after"
    t.integer "delivery_type"
    t.text "name"
    t.text "company1"
    t.text "company2"
    t.text "company3"
    t.text "phone_number"
    t.text "email_address"
    t.text "library_card_number"
    t.text "customer_type_old"
    t.text "comments"
    t.text "form_lang"
    t.text "authors"
    t.text "order_number"
    t.text "delivery_place"
    t.text "invoicing_name"
    t.text "invoicing_address"
    t.text "invoicing_postal_address1"
    t.text "invoicing_postal_address2"
    t.text "order_path"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "pickup_location_id"
    t.integer "status_id"
    t.text "libris_lf_number"
    t.integer "libris_request_id"
    t.text "librisid"
    t.text "librismisc"
    t.text "invoicing_id"
    t.integer "sticky_note_id"
    t.string "lending_library", limit: 255
    t.boolean "is_archived"
    t.integer "delivery_source_id"
    t.text "loan_period"
    t.integer "price"
    t.boolean "to_be_invoiced"
    t.text "delivery_address"
    t.text "delivery_postal_code"
    t.text "delivery_city"
    t.text "x_account"
    t.text "invoicing_company"
    t.text "publication_type"
    t.text "period"
    t.text "delivery_box"
    t.text "delivery_comments"
    t.integer "managing_group_id"
    t.integer "delivery_method_id"
    t.integer "customer_type_id"
    t.string "authenticated_x_account"
    t.integer "koha_borrowernumber"
    t.string "koha_user_category"
    t.string "koha_organisation"
    t.index ["customer_type_id"], name: "index_orders_on_customer_type_id"
  end

  create_table "orders_old", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.integer "order_type_id"
    t.text "title"
    t.text "publication_year"
    t.text "volume"
    t.text "issue"
    t.text "pages"
    t.text "journal_title"
    t.text "issn_isbn"
    t.text "reference_information"
    t.boolean "photocopies_if_loan_not_possible"
    t.boolean "order_outside_scandinavia"
    t.boolean "email_confirmation"
    t.text "not_valid_after"
    t.integer "delivery_type"
    t.text "name"
    t.text "company1"
    t.text "company2"
    t.text "company3"
    t.text "phone_number"
    t.text "email_address"
    t.text "library_card_number"
    t.text "customer_type_old"
    t.text "comments"
    t.text "form_lang"
    t.text "authors"
    t.text "order_number"
    t.text "delivery_place"
    t.text "invoicing_name"
    t.text "invoicing_address"
    t.text "invoicing_postal_address1"
    t.text "invoicing_postal_address2"
    t.text "order_path"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "pickup_location_id"
    t.integer "status_id"
    t.text "libris_lf_number"
    t.integer "libris_request_id"
    t.text "librisid"
    t.text "librismisc"
    t.text "invoicing_id"
    t.integer "sticky_note_id"
    t.string "lending_library", limit: 255
    t.boolean "is_archived"
    t.integer "delivery_source_id"
    t.text "loan_period"
    t.integer "price"
    t.boolean "to_be_invoiced"
    t.text "delivery_address"
    t.text "delivery_postal_code"
    t.text "delivery_city"
    t.text "x_account"
    t.text "invoicing_company"
    t.text "publication_type"
    t.text "period"
    t.text "delivery_box"
    t.text "delivery_comments"
    t.integer "managing_group_id"
    t.integer "delivery_method_id"
    t.integer "customer_type_id"
    t.string "authenticated_x_account"
    t.integer "koha_borrowernumber"
    t.string "koha_user_category"
  end

  create_table "pickup_locations", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.string "name_sv", limit: 255
    t.string "name_en", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "is_sigel"
    t.string "sigel", limit: 255
    t.boolean "is_active"
    t.boolean "is_available", default: true
    t.string "code"
  end

  create_table "status_group_members", id: :serial, force: :cascade do |t|
    t.integer "status_id"
    t.integer "status_group_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "status_groups", id: :serial, force: :cascade do |t|
    t.string "name_sv", limit: 255
    t.string "name_en", limit: 255
    t.string "label", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "position"
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.string "name_sv", limit: 255
    t.string "name_en", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "label", limit: 255
    t.boolean "is_active"
    t.integer "position"
  end

  create_table "tmp_borrowernumber_categorycode", id: false, force: :cascade do |t|
    t.integer "borrowernumber"
    t.string "categorycode"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "xkonto", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "pickup_location_id"
    t.integer "managing_group_id"
  end

  add_foreign_key "order_types", "managing_groups", column: "default_managing_group_id"
  add_foreign_key "orders", "customer_types"
  add_foreign_key "orders", "pickup_locations", name: "orders_location_id_fkey"
  add_foreign_key "orders", "statuses", name: "orders_status_id_fkey"
  add_foreign_key "orders", "users", name: "orders_user_id_fkey"
end
