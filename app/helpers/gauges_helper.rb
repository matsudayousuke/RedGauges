module GaugesHelper
  def get_start_of_week(target)
    target - target.wday 
  end

  def get_end_of_week(target)
    get_start_of_week(target) + 6
  end

  def get_week(date)
    get_start_of_week(date) .. get_end_of_week(date)
  end
end
