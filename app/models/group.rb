class Group < ActiveRecord::Base
	belongs_to :owner, :class_name => "User"

	has_many :memberships
	has_many :members, :through => :memberships, :dependent => :delete_all

	has_many :visibilities, -> { order("position ASC") }

	def contains_user_id(user_id)
		return !self.members.find_by_id(user_id).nil?
	end

end
