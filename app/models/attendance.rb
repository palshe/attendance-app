class Attendance < ApplicationRecord
  belong_to :worker
  default_scope -> { order(date: :desc)}
end
