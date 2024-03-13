class WorkersController < ApplicationController
  before_action :logged_in_admin?

  def show
    @worker = Worker.find(params[:id])
    @attendances = @worker.attendances.paginate(page: params[:page])
  end

  def overtime
    @worker = Worker.includes(:attendances).find(params[:id])
    if !params[:worker].blank?
      if !params[:worker][:start].blank?
        if !params[:worker][:end].blank?
          @start_date = Date.parse(params[:worker][:start])
          @end_date = Date.parse(params[:worker][:end])
          if (@end_date - @start_date).to_i < 0
            flash[:danger] = "検索日が不適切です。"
            redirect_to @worker, status: :unprocessable_entity
          else
            @attendances = Attendance.where("worker_id = ? and date >= ? and date <= ?", @worker.id, @start_date, @end_date)
            if !@attendances.blank?
              @overtime = 0.0
              @attendances.each do |at|
                @overtime += at.overtime
              end
              @overtime
              flash.now[:success] = "検索しました。"
            else
              flash[:danger] = "レコードが存在しない日付を選択しています。"
              redirect_to @worker, status: :unprocessable_entity
            end
          end
        else
          flash[:danger] = "日付を入力してください。"
          redirect_to @worker, status: :unprocessable_entity
        end
      else
        flash[:danger] = "日付を入力してください。"
        redirect_to @worker, status: :unprocessable_entity
      end
    else
    flash[:danger] = "日付を入力してください。"
    redirect_to @worker, status: :unprocessable_entity
    end
  end

  def new
    @worker = Worker.new
  end

  def create
    @worker = Worker.new(worker_params)
    if @worker.save
      flash[:success] = "#{@worker.name}の追加が完了しました。"
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
end
