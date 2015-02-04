class Subscription < ActiveRecord::Base

  enum visibility: [ :invisible, :busy, :visible, :modify ]
  enum email_notification_time_unit: [ :minutes, :hours, :days ]

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscribed_event, class_name: "Event"

  validates :subscriber, presence: true
  validates :subscribed_event, presence: true

end
