class RequestMap < ActiveRecord::Base
  belongs_to :event
  has_many :requests, :dependent => :destroy

  def pending_requests
    requests.where(:status => Request.statuses[:pending])
  end

  def confirmed_requests
    requests.where(:status => Request.statuses[:confirmed])
  end

  def modification_requests
    requests.where(:status => Request.statuses[:modify])
  end

  def declined_requests
    requests.where(:status => Request.statuses[:declined])
  end

  def removed_requests
    requests.where(:status => Request.statuses[:removed])
  end

  def generate_requests_for_ids(users)
    users.each do |u|
      self.requests << Request.create(:user_id => u, :request_map_id => id)
    end
  end

end
