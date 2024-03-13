class AttendancesController < ApplicationController
  before_action :logged_in_admin?, only: [:create]

  def attendance
    if @worker = Worker.find_by(name: params[:worker][:name])
      if params[:worker][:attendance_type] == "arrival"
        if update_todays_attendance("arrived")
          flash[:success] = "#{@attendance_today.arrived_at.to_fs(:ja)} #{@worker.name}の出勤が完了しました。"
          redirect_to root_path
          return
        else
          flash[:danger] = "エラーが発生しました。管理者に連絡してください。"
        end
      else
        if params[:worker][:attendance_type] == "left"
          if update_todays_attendance("left")
            if overtime_cul
              flash[:success] = "#{@attendance_today.arrived_at.to_fs(:ja)} #{@worker.name}の退勤が完了しました。"
              redirect_to root_path
              return
            else
              flash[:danger] = "出勤を忘れています。出勤するか、管理者に報告してください。"
            end
          else
            flash[:danger] = "エラーが発生しました。管理者に連絡してください。"
          end
        else
          flash[:danger] = "出退勤を選んでください。"
        end
      end
    else
      flash[:danger] = "#{params[:worker][:name]}は見つかりませんでした。"
    end
    redirect_to root_path, status: :unprocessable_entity
  end

  def create
    @workers = Worker.all
    today = Date.current
    begin
      @workers.each do |worker|
        worker.attendances.create!(date: today)
      end
      flash[:success] = "本日のレコードを作成しました。"
    rescue => e
      flash[:danger] = "本日のレコードはすでに作られています。"
    end
    redirect_to root_path
  end

  private

    def update_todays_attendance(attribute)
      if @attendance_today = @worker.attendances.find_by(date: Date.current)
        @attendance_today.update_attribute("#{attribute}_at", Time.zone.now)
      end
      @attendance_today
    end

    def overtime_cul
      if @attendance_today.arrived_at.nil?
      else
        overtime = (@attendance_today.left_at - @attendance_today.arrived_at) - 8.hours
        if overtime < 0
          @attendance_today.update_attribute(:overtime, 0)
        else
          @attendance_today.update_attribute(:overtime, overtime)
        end
      end
      @attendance_today.overtime
    end
end
