require 'rails_helper'

RSpec.describe WorkersController, type: :request do
  let(:admin){ create(:admin) }
  let(:worker){ create(:worker) }
  before(:each) do
    admin.reload
    worker.reload
    post login_path, params: { session: { password: "111111",
                                          password_confirmation: "111111" }}
  end
  describe "show" do
    it "正しく表示されるか" do
      get worker_path(worker)
      expect(response).to have_http_status(200)
    end
  end

  describe "new" do
    it "正しく表示されるか" do
      get new_worker_path
      expect(response).to have_http_status(200)
    end
  end

  describe "create" do
    it "正しく入力すると人数が1人増える" do
      expect{ post workers_path, params: { worker: { name: "イシイハルキ" }} }.to change{ Worker.count }.by(1)
      expect(response).to redirect_to new_worker_path
      follow_redirect!
      expect(response.body).to include "イシイハルキの追加が完了しました。"
    end
    it "空欄だと422" do
      expect{ post workers_path, params: { worker: { name: "" }} }.to change{ Worker.count }.by(0)
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "同じ名前だと422" do
      expect{ post workers_path, params: { worker: { name: "石井春輝" }} }.to change{ Worker.count }.by(0)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "edit" do
    it "正しく表示されるか" do
      get edit_worker_path(worker)
      expect(response).to have_http_status(200)
    end
  end

  describe "update" do
    let(:worker2){ create(:worker, name: "ishiiharuki") }
    it "正しい入力で名前が変わる" do
      patch worker_path(worker), params: { worker: { name: "石井ハルキ" }}
      expect(response).to redirect_to worker_path(worker)
      follow_redirect!
      expect(response.body).to include "名前を変更しました。"
      worker.reload
      expect(worker.name).to eq "石井ハルキ"
    end
    it "同じ名前はだと422" do
      worker2.reload
      patch worker_path(worker), params: { worker: { name: "ishiiharuki" }}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "destroy" do
    it "人数が1人減る" do
      expect{ delete worker_path(worker) }.to change{ Worker.count }.by(-1)
      expect(response).to redirect_to workers_path
    end
  end

  describe "index" do
    it "正しく表示されるか" do
      get workers_path
      expect(response).to have_http_status(200)
    end
  end

  describe "overtime" do
    let(:attendance) { create(:attendance, worker: worker) }
    before(:each) do
      attendance.reload
    end
    it "正しい入力で正しく表示" do
      get overtime_worker_path(worker), params: { worker: {start: "2024-02-01", end: "2024-02-01"} }
      expect(response).to have_http_status(200)
      expect(response.body).to include "検索しました。"
    end
    it "空欄で422" do
      get overtime_worker_path(worker), params: { worker: {start: nil, end: nil} }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "レコードが存在しない日付で422" do
      get overtime_worker_path(worker), params: { worker: {start: "2024-03-12", end: "2024-03-18"} }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "開始と終了が逆で422" do
      get overtime_worker_path(worker), params: { worker: {start: "2024-02-01", end: "2024-01-20"} }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end