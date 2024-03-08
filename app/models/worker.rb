class Worker < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :attendances, dependent: :destroy
end
