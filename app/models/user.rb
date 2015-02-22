class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Added by @brianbolze and @jeffday -- 2/2
  has_many :created_events, :foreign_key => 'creator_id', :class_name => 'Event', :dependent => :destroy

  has_many :subscriptions, :foreign_key => 'subscriber_id', :dependent => :delete_all
  has_many :subscribed_events, :through => :subscriptions

  #model logic by @henriquemoraes

  has_many :memberships, :foreign_key => 'member_id'
  has_many :groups, :foreign_key => 'owner_id', :class_name => 'Group'
  has_many :to_dos,-> {order('position ASC')}, :foreign_key => 'creator_id', :class_name => 'ToDo'

  has_many :visibilities, -> { order("position ASC") }, :dependent => :delete_all
  
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

  def get_visible_events
    return get_events_for_status('visible')
  end

  def get_busy_events
    events = get_events_for_status('busy')
    events.each do |e|
      e.description = ''
      e.title = "#{e.creator.email} is busy"
    end
    return events
  end

  def get_modifiable_events
    return get_events_for_status('modify')
  end

  private

  def get_events_for_status(status)
    events = []
    self.subscribed_events.each do |e|
      events << e if e.is_right_visibility_for_user(status, self.id)
    end
    return events
  end
  
end
