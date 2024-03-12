require 'rails_helper'

RSpec.describe Worker, type: :model do
  let(:worker1) { create(:worker) }
  let(:worker2) { build(:worker, name: "いしいはるき") }
  it "名前があれば有効" do
    expect(worker2).to be_valid
  end
  it "名前がなければ無効" do
    worker2.name = ""
    expect(worker2).to be_invalid
  end
  it "名前が同じなら無効" do
    p worker1
    worker2.name = "石井春輝"
    expect(worker2).to be_invalid
  end
end
