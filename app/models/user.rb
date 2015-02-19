class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Added by @brianbolze and @jeffday -- 2/2
  has_many :created_events, :foreign_key => "creator_id", :class_name => "Event"

  has_many :subscriptions, :foreign_key => "subscriber_id"
  has_many :subscribed_events, :through => :subscriptions

  has_many :memberships, :foreign_key => "member_id"
  has_many :groups, :foreign_key => "owner_id", :class_name => "Group"

  has_many :visibilities
  
  validates_presence_of :name, :email, :encrypted_password

  def has_subscription_to_event(event_id)
    puts "GOT TO METHOD, WILL RETURN, USER ID #{self.id} EVENT ID #{event_id} #{!(self.subscribed_events.find_by_id(event_id).nil?)}"
    return !(self.subscribed_events.find_by_id(event_id).nil?)
  end

  def subscribe_to_event(event)
    if Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).empty?
      Subscription.create(subscribed_event_id: event.id,subscriber_id: self.id)
    end
  end

  def unsubscribe_to_event(event)
    if !Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).empty?
      Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).first.destroy
    end
  end
  
end
