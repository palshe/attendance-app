class Worker < ApplicationRecord
  has_many :attendances, dependent: :destroy
  
end
