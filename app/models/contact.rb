class Contact < ActiveRecord::Base
  validates_uniqueness_of :email
  belongs_to :company
  has_many :contacts_tags
  has_many :tags , :through=>:contacts_tags

end
