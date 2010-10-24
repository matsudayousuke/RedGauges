module GaugesHelper
  def get_start_of_week(target)
    return target - 6 if target.wday == 0
    target - target.wday + 1
  end

  def get_end_of_week(target)
    get_start_of_week(target) + 6
  end

  def get_week(date)
    get_start_of_week(date) .. get_end_of_week(date)
  end

  def issues_tip(issues)
    ret = '<table class="list">'
    issues.each do |i|
      ret += '<tr id="tip-issue_' + i.id.to_s + '" class="' + cycle('odd', 'even') + '">'
      ret += '<td>' + i.to_s + '</td>'
      ret += '</tr>'
    end
    ret += '</table>'
  end

end
