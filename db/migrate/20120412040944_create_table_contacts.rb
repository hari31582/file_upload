class CreateTableContacts < ActiveRecord::Migration
  def self.up
    
	create_table :contacts do |t|
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
  end

  def self.down
    drop_table :contacts  
  end
end
