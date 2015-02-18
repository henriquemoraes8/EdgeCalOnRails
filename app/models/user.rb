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
  has_many :member_of_group, :through => :memberships

  has_many :visibilities
  
  validates_presence_of :name, :email, :encrypted_password

  def has_subscription_to_event(event_id)
    puts "GOT TO METHOD"
    return !(self.subscribed_events.find(event_id).nil?)
  end
  
end
