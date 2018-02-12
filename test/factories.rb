FactoryBot.define do
  sequence :code do |n|
    "CODE-#{'%03d' % n}"
  end

  factory :movie do
    code
    cover_image "https://dummyimage.com/800"
    page "https://dummyimage.com/"
    title "Dummy Movie"
  end
end