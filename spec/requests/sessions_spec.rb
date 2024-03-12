require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  let(:admin){ create(:admin) }
  describe "new" do
    it "正しく表示されるか" do
      get login_path
      expect(response).to have_http_status(200)
    end
  end

  describe "create" do
    it "正しいパスワードでログイン" do
      admin.reload
      post login_path, params: { session: { password: "111111",
                                            password_confirmation: "111111" }}
      expect(response).to redirect_to root_path
      follow_redirect!
      expect(response.body).to include "ログインしました。"
    end
    it "間違ったパスワードでログイン" do
      admin.reload
      post login_path, params: { session: { password: "111112",
                                            password_confirmation: "111112" }}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include "パスワードが間違っています。"
    end
  end

  describe "destroy" do
    it "ログアウト" do
      admin.reload
      post login_path, params: { session: { password: "111111",
                                            password_confirmation: "111111" }}
      delete logout_path
      expect(response).to redirect_to root_path
      follow_redirect!
      expect(response.body).to include "ログアウトしました。"
    end
  end
end