class Visibility < ActiveRecord::Base
  enum status: [ :invisible, :busy, :visible, :modify ]

  belongs_to :event
  belongs_to :user
  belongs_to :group

  acts_as_list scope: :event

  validates_presence_of :event_id
end
