require 'rails_helper'

RSpec.describe AttendancesController, type: :request do
  let(:worker){ create(:worker) }
  before(:each) do
    worker.reload
  end
  describe "attendance" do
    let(:attendance){ create(:attendance, worker: worker, date: Date.current, arrived_at: nil, left_at: nil, overtime: nil)}
    before(:each) do
      attendance.reload
    end
    it "正しく出勤で200" do
      post attendance_path, params:{ worker: { name: "石井春輝", attendance_type: "arrival" } }
      expect(response).to have_http_status(:ok)
    end
    it "正しく退勤で200" do
      post attendance_path, params:{ worker: { name: "石井春輝", attendance_type: "arrival" } }
      post attendance_path, params:{ worker: { name: "石井春輝", attendance_type: "left" } }
      expect(response).to have_http_status(:ok)
    end
    it "存在しないアカウントで422" do
      post attendance_path, params:{ worker: { name: "Ishii Haruki", attendance_type: "arrival" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "退勤を先に押すで422" do
      post attendance_path, params:{ worker: { name: "石井春輝", attendance_type: "left" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "出退勤を選択しないで422" do
      post attendance_path, params:{ worker: { name: "石井春輝", attendance_type: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "create" do
    let(:admin){ create(:admin) }
    before(:each) do
      admin.reload
    end
    it "1回目はレコード作成が成功、2回目は失敗" do
      post login_path, params: { session: { password: "111111",
                                            password_confirmation: "111111" }}
      expect{ get attendance_path }.to change{ worker.attendances.count }.by(1)
      expect{ get attendance_path }.to change{ worker.attendances.count }.by(0)
    end
  end
end