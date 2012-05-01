class ContactsTag < ActiveRecord::Base
  validates_uniqueness_of :tag_id , :scope=>:contact_id
  belongs_to :tag
  belongs_to :contact
end
