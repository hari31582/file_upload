class ContactsTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :contact
end
