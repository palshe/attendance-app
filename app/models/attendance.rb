class Attendance < ApplicationRecord
  belongs_to :worker
  default_scope -> { order(date: :desc)}
end
