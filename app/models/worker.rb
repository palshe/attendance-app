class Worker < ApplicationRecord
  validates :name, presence: true
  has_many :attendances, dependent: :destroy
  
end
