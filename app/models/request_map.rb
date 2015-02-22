class RequestMap < ActiveRecord::Base
  belongs_to :event
  has_many :requests
end
