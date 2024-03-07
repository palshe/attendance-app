module SessionsHelper

  #ログインする
  def log_in(admin)
    session[:admin_id] = admin.id
  end

  #ログアウトする
  def log_out
    reset_session
  end

  #ログインしているか確認する
  def logged_in?
    !!session[:admin_id]
  end
end
