Worker.create!(
  name: "石井春輝",
)

worker = Worker.first
worker.attendances.create!(
  date: Date.today
)