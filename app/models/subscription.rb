class Subscription < ActiveRecord::Base

  enum email_notification_time_unit: [ :minutes, :hours, :days ]

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscribed_event, class_name: "Event"
  has_one :reminder

  #validates :subscriber, presence: true
  #validates :subscribed_event, presence: true

  validates :subscriber, presence: true
  validates :subscribed_event, presence: true


end
