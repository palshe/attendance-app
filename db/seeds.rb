Admin.create!(
  password: "111111",
  password_confirmation: "111111"
)

Worker.create!(
name: "石井春輝",
)

99.times do |n|
  name = Faker::Name.name
  Worker.create!(name: name)
end

worker = Worker.first
setting_day = Time.new(2024, 2, 1, 0, 0, 0)
(0..28).each do |n|
  arrived = (setting_day + n.days) + 9.hours
  left = arrived + 8.hours + (10*n).minutes + 10*n
  if left - arrived - 8.hours < 0
    over = 0
  else
    over = left - arrived - 8.hours
  end
  worker.attendances.create!(
    date: Date.new(2024, 2, 1 + n),
    arrived_at: arrived,
    left_at: left,
    overtime: over
  )
end

worker.attendances.create!(
  date: Date.today
)