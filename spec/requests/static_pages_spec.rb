require 'rails_helper'

RSpec.describe "StaticPagesControllerとView", type: :request do
  let(:admin){ create(:admin) }
  describe "home" do
    it "ログインしていない状態で正しく表示されるか" do
      get root_path
      expect(response).to have_http_status(200)
      expect(response.body).to include "名前"
    end
    it "ログインしている状態で正しく表示されるか" do
      admin.reload
      post login_path, params: { session: { password: "111111",
                                            password_confirmation: "111111" }}
      get root_path
      expect(response).to have_http_status(200)
      expect(response.body).to include "従業員追加"
    end
  end
end