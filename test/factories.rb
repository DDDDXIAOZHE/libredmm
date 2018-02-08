FactoryBot.define do
  sequence :code do |n|
    "CODE-#{'%03d' % n}"
  end

  factory :movie do
    code
  end
end