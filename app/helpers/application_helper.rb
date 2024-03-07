module ApplicationHelper
  #完全なタイトルを返す
  def full_title(title = "")
    if title.nil?
      "勤怠くん"
    else
      "#{title} | 勤怠くん"
    end
  end

  #ビューのコメントアウト用
  def comment_out
  end
end
