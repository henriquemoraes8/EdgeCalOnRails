class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Added by @brianbolze and @jeffday -- 2/2
  has_many :created_events, :foreign_key => 'creator_id', :class_name => 'Event', :dependent => :destroy
  has_and_belongs_to_many :allowed_signups, :class_name => 'RepetitionScheme'

  has_many :subscriptions, :foreign_key => 'subscriber_id', :dependent => :destroy
  has_many :subscribed_events, :through => :subscriptions
  has_many :slot_schemes, :foreign_key => 'creator_id', :class_name => 'RepetitionScheme', :dependent => :destroy

  #model logic by @henriquemoraes

  has_many :memberships, :foreign_key => 'member_id', :dependent => :delete_all
  has_many :groups, :foreign_key => 'owner_id', :class_name => 'Group', :dependent => :delete_all
  has_many :to_dos,-> {order('position ASC')}, :foreign_key => 'creator_id', :class_name => 'ToDo', :dependent => :destroy

  has_many :visibilities, -> { order("position ASC") }, :dependent => :delete_all
  has_many :requests, :dependent => :destroy

  has_many :time_slots, :dependent => :delete_all
  
  validates_presence_of :name, :email, :encrypted_password

  def has_subscription_to_event(event_id)
    puts "GOT TO METHOD, WILL RETURN, USER ID #{self.id} EVENT ID #{event_id} #{!(self.subscribed_events.find_by_id(event_id).nil?)}"
    return !(self.subscribed_events.find_by_id(event_id).nil?)
  end

  def subscribe_to_event(event)
    if Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).empty?
      return Subscription.create(subscribed_event_id: event.id,subscriber_id: self.id)
    end
    Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).first
  end

  def unsubscribe_to_event(event)
    if !Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).empty?
      return Subscription.where(subscribed_event_id: event.id,subscriber_id: self.id).first.destroy
    end
  end

  def get_visible_events
    get_events_for_status('visible')
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

  def get_requested_events
    created_events.where(:event_type => Event.event_types[:request])
  end

  def get_time_slot_created_events
    all_events = []
    created_events.where(:event_type => Event.event_types[:time_slot_block]).map {|e| all_events << e}
    slot_schemes.map {|s| s.events.map {|e| all_events << e}}
    all_events
  end

  def get_allowed_signup_schemes(user_id)
    schemes = []
    slot_schemes.map {|s| schemes << s if s.user_allowed?(user_id)}
    schemes
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
