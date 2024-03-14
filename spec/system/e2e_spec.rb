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
    describe "出退勤" do
      context "正しい操作" do
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
      context "間違った操作" do
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
  end
  describe "管理者としての操作" do
    describe "ログイン" do
      context "正しい操作" do
        it "正しいパスワードを入力してログアウトする" do
          visit root_path
          click_link "管理者用ログイン"
          expect(current_path).to eq login_path
          expect(page).to have_link "ホームに戻る", href: root_path
          fill_in 'session[password]', with: "111111"
          click_button "ログイン"
          expect(page).to have_content "ログインしました。"
          expect(page).to have_link "ログアウト", href: logout_path
          click_link "ログアウト"
          expect(page).to have_content "ログアウトしました。"
          expect(page).to have_link "管理者用ログイン", href: login_path
        end
      end
      context "間違った操作" do
        it "間違ったパスワードを入力する" do
          visit login_path
          fill_in 'session[password]', with: "111112"
          click_button "ログイン"
          expect(page).to have_http_status(:unprocessable_entity)
          expect(current_path).to eq login_path
          expect(page).to have_content "パスワードが間違っています。"
        end
      end
    end
    describe "従業員の追加、レコード作成" do
      before do
        visit login_path
        fill_in 'session[password]', with:"111111"
        click_button "ログイン"
      end
      context "正しい操作" do
        it "従業員追加を押して正しく入力したあと、本日のレコードを追加する" do
          click_link "従業員追加"
          expect(page).to have_field 'worker[name]'
          fill_in 'worker[name]', with: "いしいはるき"
          click_button "追加する"
          expect(current_path).to eq new_worker_path
          expect(page).to have_content "いしいはるきの追加が完了しました。"
          click_link "ホームに戻る"
          click_link "本日のレコードを作成"
          expect(current_path).to eq root_path
          expect(page).to have_content "本日のレコードを作成しました。"
        end
      end
      context "間違った操作" do
        it "従業員の名前が空欄" do
          visit new_worker_path
          fill_in 'worker[name]', with: ""
          click_button "追加する"
          expect(page).to have_http_status(:unprocessable_entity)
          visit new_worker_path
          expect(page).to have_content "名前が入力されていないか、すでに存在する従業員です。"
        end
        it "同じ名前の従業員を追加" do
          visit new_worker_path
          fill_in 'worker[name]', with: "石井春輝"
          click_button "追加する"
          expect(page).to have_http_status(:unprocessable_entity)
          visit new_worker_path
          expect(page).to have_content "名前が入力されていないか、すでに存在する従業員です。"
        end
        it "同じ日のレコードを2度作成" do
          visit root_path
          click_link "本日のレコードを作成"
          click_link "本日のレコードを作成"
          expect(page).to have_content "本日のレコードはすでに作られています。"
        end
        it "レコードを作成してから、従業員を追加して、またレコードを作成" do
          visit root_path
          expect(page.status_code).to eq (200)
          expect(current_path).to eq root_path
          expect(page).to have_link "本日のレコードを作成", href: attendances_create_path
          click_link "本日のレコードを作成"
          visit new_worker_path
          fill_in 'worker[name]', with: "いしいはるき"
          click_button "追加する"
          visit root_path
          click_link "本日のレコードを作成"
          expect(page).to have_content "本日のレコードはすでに作られています。"
        end
      end
    end
  end
end