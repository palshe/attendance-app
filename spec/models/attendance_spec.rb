require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let (:worker) { create(:worker) }
  let(:attendance1) { create(:attendance, worker: worker) }
  let(:attendance2) { build(:attendance, worker: worker) }
  it "有効な場合" do
    date = attendance1.date + 1
    attendance2.date = date
    expect(attendance2).to be_valid
  end
  it "降順か？" do
    attendance2.save
    expect(worker.attendances.first).to eq attendance2
  end
end
