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

ActiveRecord::Schema[7.0].define(version: 2026_01_10_153829) do
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

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "autonomo_payments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "paid"
    t.datetime "uploaded_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fiscal_quarter_id"
    t.index ["fiscal_quarter_id"], name: "index_autonomo_payments_on_fiscal_quarter_id"
    t.index ["user_id"], name: "index_autonomo_payments_on_user_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer "bank_connection_id", null: false
    t.string "account_id"
    t.string "account_name"
    t.string "account_type"
    t.string "currency"
    t.decimal "balance", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_connection_id"], name: "index_bank_accounts_on_bank_connection_id"
  end

  create_table "bank_connections", force: :cascade do |t|
    t.string "provider"
    t.text "access_token"
    t.text "refresh_token"
    t.datetime "expires_at"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "bank_account_id", null: false
    t.date "date"
    t.string "description"
    t.decimal "amount", precision: 15, scale: 2
    t.string "currency", default: "EUR"
    t.string "transaction_type"
    t.string "merchant"
    t.boolean "work_expense", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
  end

  create_table "brain_dump_taggings", force: :cascade do |t|
    t.integer "brain_dump_id", null: false
    t.integer "brain_dump_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brain_dump_id"], name: "index_brain_dump_taggings_on_brain_dump_id"
    t.index ["brain_dump_tag_id"], name: "index_brain_dump_taggings_on_brain_dump_tag_id"
  end

  create_table "brain_dump_tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brain_dump_tags_on_name", unique: true
  end

  create_table "brain_dumps", force: :cascade do |t|
    t.text "content"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "raw_content"
  end

  create_table "btys", force: :cascade do |t|
    t.boolean "value", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_btys_on_date", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.integer "user_id"
    t.boolean "is_draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "developer_leaves", force: :cascade do |t|
    t.integer "tonic_developer_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_date", "end_date"], name: "index_developer_leaves_on_start_date_and_end_date"
    t.index ["tonic_developer_id"], name: "index_developer_leaves_on_tonic_developer_id"
  end

  create_table "digest_brain_dumps", force: :cascade do |t|
    t.integer "digest_id", null: false
    t.integer "brain_dump_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brain_dump_id"], name: "index_digest_brain_dumps_on_brain_dump_id"
    t.index ["digest_id"], name: "index_digest_brain_dumps_on_digest_id"
  end

  create_table "digest_messages", force: :cascade do |t|
    t.integer "digest_id", null: false
    t.string "role"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["digest_id"], name: "index_digest_messages_on_digest_id"
  end

  create_table "digests", force: :cascade do |t|
    t.string "digest_type"
    t.string "schedule_period"
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fiscal_quarters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.string "status", default: "active"
    t.text "notes"
    t.string "identifier"
    t.string "passcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.string "quarter"
    t.decimal "total_tax_submitted", precision: 10, scale: 2, default: "0.0"
    t.index ["user_id"], name: "index_fiscal_quarters_on_user_id"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "description"
    t.decimal "rate"
    t.integer "quantity"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "frequency"
    t.decimal "rate"
    t.string "recipient_company_name"
    t.string "recipient_vat_number"
    t.text "recipient_address"
    t.string "recipient_email"
    t.string "sender_company_name"
    t.string "sender_tax_number"
    t.text "sender_address"
    t.date "issued_on"
    t.date "due_on"
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_number"
    t.decimal "tax_rate", precision: 5, scale: 2
    t.text "terms"
    t.text "bank_details"
    t.text "notes"
    t.string "currency", default: "EUR", null: false
    t.integer "fiscal_quarter_id"
    t.index ["fiscal_quarter_id"], name: "index_invoices_on_fiscal_quarter_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.text "identifier"
    t.text "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outgoing_receipts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "paid"
    t.datetime "uploaded_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fiscal_quarter_id"
    t.string "service"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "EUR"
    t.integer "service_id"
    t.integer "month"
    t.integer "year"
    t.boolean "assigned", default: false, null: false
    t.index ["fiscal_quarter_id"], name: "index_outgoing_receipts_on_fiscal_quarter_id"
    t.index ["user_id"], name: "index_outgoing_receipts_on_user_id"
  end

  create_table "service_accounts", force: :cascade do |t|
    t.integer "service_id", null: false
    t.string "login_email"
    t.string "login_password"
    t.text "session_cookies"
    t.datetime "last_authenticated_at"
    t.string "login_url"
    t.string "invoice_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_accounts_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "description"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "EUR"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "variable_amount", default: false
    t.boolean "active", default: true
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "tonic_developers", force: :cascade do |t|
    t.string "name", null: false
    t.string "project"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.text "first_name"
    t.text "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "autonomo_payments", "fiscal_quarters"
  add_foreign_key "autonomo_payments", "users"
  add_foreign_key "bank_accounts", "bank_connections"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "brain_dump_taggings", "brain_dump_tags"
  add_foreign_key "brain_dump_taggings", "brain_dumps"
  add_foreign_key "developer_leaves", "tonic_developers"
  add_foreign_key "digest_brain_dumps", "brain_dumps"
  add_foreign_key "digest_brain_dumps", "digests"
  add_foreign_key "digest_messages", "digests"
  add_foreign_key "fiscal_quarters", "users"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "fiscal_quarters"
  add_foreign_key "invoices", "users"
  add_foreign_key "outgoing_receipts", "fiscal_quarters"
  add_foreign_key "outgoing_receipts", "users"
  add_foreign_key "service_accounts", "services"
  add_foreign_key "services", "users"
end
