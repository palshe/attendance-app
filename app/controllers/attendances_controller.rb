class AttendancesController < ApplicationController

  def attendance
    if @worker = Worker.find_by(name: params[:worker][:name])
      if params[:worker][:attendance_type] == "arrival"
        update_todays_attendance("arrived")
        flash[:success] = "#{@attendance_today.arrived_at.to_s(:ja)} #{@worker.name}の出勤が完了しました。"
      else
        if params[:worker][:attendance_type] == "left"
          update_todays_attendance("left")
          overtime_cul
          flash[:success] = "#{@attendance_today.arrived_at.to_s(:ja)} #{@worker.name}の退勤が完了しました。残業時間は#{@attendance_today.overtime.to_s}秒です"
        else
          flash[:danger] = "出退勤を選んでください。"
        end
      end
    else
      flash[:danger] = "#{params[:worker][:name]}は見つかりませんでした。"
    end
    redirect_to root_path
  end

  def update_todays_attendance(attribute)
    @attendance_today = @worker.attendances.find_by(date: Date.today)
    @attendance_today.update_attribute("#{attribute}_at", Time.now)
  end

  def overtime_cul
    overtime = (@attendance_today.left_at - @attendance_today.arrived_at) - 8.hours
    if overtime < 0
      @attendance_today.update_attribute(:overtime, 0)
    else
      @attendance_today.update_attribute(:overtime, overtime)
    end
  end
end
