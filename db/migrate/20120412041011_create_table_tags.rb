class CreateTableTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
  t.string   "name"
  t.datetime "created_at"
  t.datetime "updated_at"
end
  end

  def self.down
    drop_table :tags
  end
end
