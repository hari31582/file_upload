# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120414170010) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "status"
    t.string   "fax"
    t.string   "revenues"
    t.integer  "employees"
    t.string   "industry"
    t.integer  "contacts_count",                   :default => 0
    t.string   "description",      :limit => 2000
    t.string   "ownership"
    t.string   "sic_code"
    t.string   "ticker_symbol",    :limit => 5
    t.string   "category"
    t.string   "billing_address"
    t.string   "shipping_address"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "status"
    t.string   "department"
    t.boolean  "do_not_call"
    t.string   "source"
    t.string   "mobile"
    t.string   "fax"
    t.string   "salutation",  :limit => 5
    t.string   "reports_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts_tags", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_by"], :name => "index_delayed_jobs_on_locked_by"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
