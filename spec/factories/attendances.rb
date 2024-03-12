FactoryBot.define do
  factory :attendance do
    date { Time.zone.parse("2024-02-01").to_date }
    arrived_at { Time.zone.parse("2024-02-01 09:00:00") }
    left_at { Time.zone.parse("2024-02-01 20:00:00")  }
    overtime { 3.hours.to_f }
    association :worker
  end
end