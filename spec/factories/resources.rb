# frozen_string_literal: true

FactoryBot.define do
  sequence :uri do |n|
    "https://foobar.com/#{n}"
  end

  sequence :baidu_pan_uri do |n|
    "http://pan.baidu.com/s/#{n}"
  end

  sequence :torrent_uri do |n|
    "http://foobar.com/#{n}.torrent"
  end

  factory :resource do
    movie
    download_uri { generate :uri }
    is_obsolete { false }
  end
end
