class RequestMap < ActiveRecord::Base
  belongs_to :event
  has_many :requests, :dependent => :delete_all
end
