require 'rails_helper'

RSpec.describe "エンドツーエンド", type: :system do
  let(:worker){ create(:worker) }
  let(:admin){ create(:admin) }
  before(:each) do
    worker.reload
    admin.reload
  end
  describe "従業員としての操作" do
    let(:attendance){ create(:attendance, worker: worker, date: Date.current, arrived_at: nil, left_at: nil, overtime: nil) }
    before(:each) do
      attendance.reload
      visit root_path
      fill_in 'worker[name]', with: "石井春輝"
    end
    context "正しい動作" do
      it "出勤したあと退勤する" do
        choose 'worker_attendance_type_arrival'
        click_button "送信"
        attendance.reload
        expect(attendance.arrived_at.nil?).to be_falsey
        expect(current_path).to eq root_path
        expect(page).to have_content "#{attendance.arrived_at.to_fs(:ja)} #{worker.name}の出勤が完了しました。"
        fill_in 'worker[name]', with: "石井春輝"
        choose 'worker_attendance_type_left'
        click_button "送信"
        attendance.reload
        expect(attendance.left_at.nil?).to be_falsey
        expect(current_path).to eq root_path
        expect(page).to have_content "#{attendance.arrived_at.to_fs(:ja)} #{worker.name}の退勤が完了しました。"
      end
    end
    context "間違った動作" do
      it "名前が間違っている" do
        fill_in 'worker[name]', with: ""
        choose 'worker_attendance_type_arrival'
        click_button "送信"
        attendance.reload
        expect(attendance.arrived_at.nil?).to be_truthy
        expect(page).to have_http_status(:unprocessable_entity)
        visit root_path
        expect(page).to have_content "見つかりませんでした。"
      end
      it "出退勤を選んでいない" do
        click_button "送信"
        expect(page).to have_http_status(:unprocessable_entity)
        visit root_path
        expect(page).to have_content "出退勤を選んでください。"
      end
      it "退勤から選んでしまう" do
        choose 'worker_attendance_type_left'
        click_button "送信"
        attendance.reload
        expect(attendance.arrived_at.nil?).to be_truthy
        expect(page).to have_http_status(:unprocessable_entity)
        visit root_path
        expect(page).to have_content "出勤を忘れています。出勤するか、管理者に報告してください。"
      end
    end
  end
  describe "管理者としての操作" do
    describe "ログイン" do
      context "正しいログイン" do
      end
      context "間違ったログイン" do
      end
    end
  end
end