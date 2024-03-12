class ApplicationController < ActionController::Base
include SessionsHelper

def logged_in_admin?
  unless logged_in?
    flash[:danger] = "管理者としてログインしてください。"
    redirect_to login_path, status: :see_other
  end
end

end
