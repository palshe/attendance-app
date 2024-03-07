class SessionsController < ApplicationController
  def new
  end

  def create
    admin = Admin.first
    if admin &. authenticate(params[:session][:password])
      reset_session
      log_in admin
      redirect_to root_path
    else
      flash.now[:danger] = "パスワードが間違っています。"
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    flash[:success] = "ログアウトしました。"
    redirect_to root_path
  end
end
