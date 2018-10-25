class User < ApplicationRecord
  include Clearance::User

  has_many(
    :votes,
    -> { where.not(status: :bookmark) },
    dependent: :destroy,
  )
  has_many(
    :upvotes,
    -> { where(status: :up) },
    class_name: 'Vote',
    dependent: :destroy,
  )
  has_many(
    :downvotes,
    -> { where(status: :down) },
    class_name: 'Vote',
    dependent: :destroy,
  )
  has_many(
    :bookmarks,
    -> { where(status: :bookmark) },
    class_name: 'Vote',
    dependent: :destroy,
  )
end
