FactoryBot.define do
  sequence :code do |n|
    "CODE-#{format('%03d', n)}"
  end

  factory :movie do
    code
    cover_image   'https://dummyimage.com/800'
    page          'https://dummyimage.com/'
    sample_images [
                    'https://dummyimage.com/555',
                    'https://dummyimage.com/666',
                    'https://dummyimage.com/777',
                  ]
    title         'Dummy Movie'
  end
end
