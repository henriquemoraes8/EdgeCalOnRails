class Group < ActiveRecord::Base
	belongs_to :owner, :class_name => "User"

	has_many :memberships
	has_many :members, :through => :memberships, :dependent => :delete_all

	has_many :visibilities, -> { order("position ASC") }

	validates_presence_of :title

	def contains_user_id(user_id)
		return !self.members.find_by_id(user_id).nil?
	end

	def all_user_ids
		ids = []
		members.each do |m|
			ids << m.id
		end
		return ids
	end

	

end
