class Contact < ActiveRecord::Base
  validates_uniqueness_of :email
  belongs_to :comnpany
end
