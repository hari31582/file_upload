class Tag < ActiveRecord::Base
   has_many :contacts_tags
   has_many :contacts , :through=>:contacts_tags
end
