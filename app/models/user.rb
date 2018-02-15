class User < ApplicationRecord
  include Clearance::User

  has_many :votes
end
