module ApplicationHelper
  def full_title(title = "")
    if title.nil?
      "勤怠くん"
    else
      "#{title} | 勤怠くん"
    end
  end

  def comment_out
  end
end
