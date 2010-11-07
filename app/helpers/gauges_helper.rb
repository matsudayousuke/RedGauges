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
#      ret += '<tr id="tip-issue_' + i.id.to_s + '" class="hascontextmenu ' + (i.closed? ? "closed":"todo") + '">'
      ret += '<tr id="tip-issue_' + i.id.to_s + '" class="hascontextmenu ">'
      ret += '<td class="checkbox">' + check_box_tag("ids[]", i.id, false, :id => nil) + '</td>'
      ret += '<td nowrap>' + 
        "#" + i.id.to_s + link_to(i.subject, :controller => 'issues', :action => 'show', :id => i) +
        '</td>'
      ret += '</tr>'
    end
    ret += '</table>'
  end

  def wday(date)
    wdays = [
      l(:label_sunday),
      l(:label_monday),
      l(:label_tuesday),
      l(:label_wednesday),
      l(:label_thursday),
      l(:label_friday),
      l(:label_saturday)
    ]
    wdays[date.wday]
  end

end
