class Subscription < ActiveRecord::Base

  enum visibility: [ :private, :busy, :visible, :modify]

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscibed_event, class_name: "Event"

  validates :subscriber, presence: true
  validates :subscibed_event, presence: true
end
