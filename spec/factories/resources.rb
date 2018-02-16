FactoryBot.define do
  sequence :uri do |n|
    "https://dummyimage.com/#{n}"
  end

  factory :resource do
    movie
    download_uri { generate :uri }
  end
end
