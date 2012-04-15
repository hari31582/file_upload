class CreateTableCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
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
  t.integer  "contacts_count", :default => 0
  t.string   "description",    :limit => 2000
  t.string   "ownership"
  t.string   "sic_code"
  t.string   "ticker_symbol",  :limit => 5
  t.string   "category"
  t.string   "billing_address"
  t.string   "shipping_address"
  t.string   "size"
  t.datetime "created_at"
  t.datetime "updated_at"
end
  end

  def self.down
   drop_table :companies
  end
end
