Admin.create!(
  password: "111111",
  password_confirmation: "111111"
)

Worker.create!(
  name: "石井春輝",
)

worker = Worker.first
worker.attendances.create!(
  date: Date.today
)