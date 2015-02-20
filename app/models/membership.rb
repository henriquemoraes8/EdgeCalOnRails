class Membership < ActiveRecord::Base

  belongs_to :member, class_name: "User"
  belongs_to :group

  validates :member, presence: true
  validates :group, presence: true

end
