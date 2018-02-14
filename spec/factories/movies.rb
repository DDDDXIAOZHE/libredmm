FactoryBot.define do
  sequence :code do |n|
    "CODE-#{format('%03d', n)}"
  end

  factory :movie do
    code
  end
end
