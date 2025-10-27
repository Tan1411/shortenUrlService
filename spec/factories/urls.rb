FactoryBot.define do
  factory :url do
    origin_url { Faker::Internet.url }
  end
end
