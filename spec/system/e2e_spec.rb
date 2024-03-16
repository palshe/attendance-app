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
          choose 'select_arrived'
          click_button "送信"
          attendance.reload
          expect(attendance.arrived_at.nil?).to be_falsey
          expect(current_path).to eq root_path
          expect(page).to have_content "#{attendance.arrived_at.to_fs(:ja)} #{worker.name}の出勤が完了しました。"
          fill_in 'worker[name]', with: "石井春輝"
          choose 'select_left'
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
          choose 'select_arrived'
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
          choose 'select_left'
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
      before(:each) do
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
    describe "従業員一覧、従業員削除、個別表示、名前変更、残業時間表示" do
      let(:other_worker){ create(:worker, name: "いしいはるき") }
      let(:attendance1){ create(:attendance, worker: worker) }
      let(:attendance2){ create(:attendance, worker: worker, date: Date.parse("2024-02-02"), arrived_at: Time.zone.parse("2024-02-02 09:00:00"), left_at: Time.zone.parse("2024-02-02 20:00:00"))}
      before(:each) do
        other_worker.reload
        attendance1.reload
        attendance2.reload
        visit login_path
        fill_in 'session[password]', with:"111111"
        click_button "ログイン"
      end
      context "正しい操作" do
        it "一覧表示をして、詳細へ移って、名前を変更した後に、残業時間を出す" do
          visit root_path
          click_link "従業員一覧"
          expect(current_path).to eq workers_path
          expect(page).to have_link "石井春輝", href: worker_path(worker)
          expect(page).to have_link "いしいはるき", href: worker_path(other_worker)
          expect(page).to have_link "削除する", href: worker_path(worker)
          expect(page).to have_link "ホームに戻る", href: root_path
          click_link "石井春輝"
          expect(page).to have_content "#{Time.zone.parse("2024-02-01 09:00:00").to_fs(:ja)}"
          expect(page).to have_content "#{Time.zone.parse("2024-02-01 20:00:00").to_fs(:ja)}"
          expect(page).to have_content "#{(attendance1.overtime/60/60).floor(2).to_s}"
          expect(page).to have_content "#{Time.zone.parse("2024-02-02 09:00:00").to_fs(:ja)}"
          expect(page).to have_content "#{Time.zone.parse("2024-02-02 09:00:00").to_fs(:ja)}"
          expect(page).to have_content "#{(attendance2.overtime/60/60).floor(2).to_s}"
          click_link "変更"
          fill_in 'worker[name]', with: "イシイハルキ"
          click_button "変更する"
          expect(current_path).to eq worker_path(worker)
          expect(page).to have_content "名前を変更しました。"
          worker.reload
          expect(worker.name).to eq "イシイハルキ"
          expect(page).to have_field 'worker[start]'
          expect(page).to have_field 'worker[end]'
          fill_in 'worker[start]', with: "002024-02-01"
          fill_in 'worker[end]', with: "002024-02-02"
          click_button "検索"
          expect(page).to have_content "検索しました。"
          expect(page).to have_content "2024年02月01日から2024年02月02日までの総残業時間は"
          expect(page).to have_content "6.0時間"
          expect(page).to have_content "#{Time.zone.parse("2024-02-01 09:00:00").to_fs(:ja)}"
          expect(page).to have_content "#{Time.zone.parse("2024-02-02 09:00:00").to_fs(:ja)}"
        end
      end
      context "間違った操作" do
        it "名前が空欄" do
          visit edit_worker_path(worker)
          fill_in 'worker[name]', with: ""
          click_button "変更する"
          visit edit_worker_path(worker)
          expect(page).to have_content "名前が入力されていないか、同じ名前の従業員が存在してます。"
        end
        it "同じ名前" do
          visit edit_worker_path(worker)
          fill_in 'worker[name]', with: "いしいはるき"
          click_button "変更する"
          visit edit_worker_path(worker)
          expect(page).to have_content "名前が入力されていないか、同じ名前の従業員が存在してます。"
        end
        it "日付を入力しない" do
          visit worker_path(worker)
          fill_in 'worker[start]', with: ""
          fill_in 'worker[end]', with: ""
          click_button "検索"
          visit worker_path(worker)
          expect(page).to have_content "日付を入力してください。"
        end
        it "開始と終了が逆" do
          visit worker_path(worker)
          fill_in 'worker[start]', with: "002024-02-02"
          fill_in 'worker[end]', with: "002024-02-01"
          click_button "検索"
          visit worker_path(worker)
          expect(page).to have_content "検索日が不適切です。"
        end
        it "存在しない日付" do
          visit worker_path(worker)
          fill_in 'worker[start]', with: "002024-07-01"
          fill_in 'worker[end]', with: "002024-07-02"
          click_button "検索"
          visit worker_path(worker)
          expect(page).to have_content "レコードが存在しない日付を選択しています。"
        end
      end
    end
  end
  describe "ログインしないでアクセス" do
    it "本日のレコード作成" do
      visit attendances_create_path
      expect(current_path).to eq login_path
    end
    it "従業員一覧" do
      visit workers_path
      expect(current_path).to eq login_path
    end
    it "従業員作成" do
      visit new_worker_path
      expect(current_path).to eq login_path
    end
    it "個別表示" do
      visit worker_path(worker)
      expect(current_path).to eq login_path
    end
    it "名前編集" do
      visit edit_worker_path(worker)
      expect(current_path).to eq login_path
    end
    it "残業時間表示" do
      visit overtime_worker_path(worker)
      expect(current_path).to eq login_path
    end
  end
end