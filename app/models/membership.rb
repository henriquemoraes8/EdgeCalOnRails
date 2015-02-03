class Membership < ActiveRecord::Base

  belongs_to :member, class_name: "User"
  belongs_to :member_of_group, class_name: "Group"

  validates :member, presence: true
  validates :member_of_group, presence: true

end
