FactoryBot.define do
  factory :vote do
    user
    movie
    status :up
  end
end
