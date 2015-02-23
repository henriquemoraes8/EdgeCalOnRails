class Request < ActiveRecord::Base
  enum status: [:pending, :confirmed, :modify, :declined, :removed]

  belongs_to :request_map
  belongs_to :user



end
