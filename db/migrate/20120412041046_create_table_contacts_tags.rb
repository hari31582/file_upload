class CreateTableContactsTags < ActiveRecord::Migration
  def self.up
    create_table :contacts_tags do |t|
      t.integer  "contact_id"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :contacts_tags
  end
end
