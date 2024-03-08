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
worker.attendances.create!(
  date: Date.today
)