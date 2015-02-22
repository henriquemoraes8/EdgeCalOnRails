class RequestMap < ActiveRecord::Base
  belongs_to :event
  has_many :requests, :dependent => :delete_all

  def pending_requests
    requests.where(:status => 'pending')
  end

  def confirmed_requests
    requests.where(:status => 'confirmed')
  end

  def declined_requests
    requests.where(:status => 'declined')
  end

  def removed_requests
    requests.where(:status => 'removed')
  end

end
