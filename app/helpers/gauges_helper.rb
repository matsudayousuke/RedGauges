module GaugesHelper
  def get_start_of_week(target)
    target - target.wday 
  end

  def get_end_of_week(target)
    get_start_of_week(target) + 6
  end

  def get_this_week
    get_start_of_week(Date.today) .. get_end_of_week(Date.today)
  end
end
