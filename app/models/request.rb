class Request < ActiveRecord::Base
  enum status: [:pending, :confirmed, :declined, :removed]

  belongs_to :request_map



end
