class Group < ActiveRecord::Base
	belongs_to :owner, :class_name => "User"

	has_many :memberships, :foreign_key => "member_of_group_id"
	has_many :members, :through => :memberships
end
