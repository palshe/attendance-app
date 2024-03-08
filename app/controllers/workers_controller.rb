class WorkersController < ApplicationController
  before_action :logged_in_admin?

  def show
    @worker = Worker.find(params[:id])
    @attendances = @worker.attendances.paginate(page: params[:page])
  end

  def new
    @worker = Worker.new
  end

  def create
    @worker = Worker.new(worker_params)
    if @worker.save
      flash[:success] = "#{@worker.name}の追加が完了しました"
      redirect_to new_worker_path
    else
      flash.now[:danger] = "名前が入力されていないか、すでに存在する従業員です。"
      render 'new' , status: :unprocessable_entity
    end
  end

  def edit
    @worker = Worker.find(params[:id])
  end

  def update
    @worker = Worker.find(params[:id])
    if @worker.update(worker_params)
      flash[:success] = "名前を変更しました。"
      redirect_to @worker
    else
      flash.now[:danger] = "名前が入力されていないか、同じ名前の従業員が存在してます。"
      render 'edit' , status: :unprocessable_entity
    end
  end

  def destroy
    Worker.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to workers_path, status: :see_other
  end

  def index
    @workers = Worker.paginate(page: params[:page])
  end

  private

    def worker_params
      params.require(:worker).permit(:name)
    end

    def logged_in_admin?
      unless logged_in?
        flash[:danger] = "管理者としてログインしてください。"
        redirect_to login_path, status: :see_other
      end
    end
end
