module FreeTimeHelper

  def weekdays
    [['Sunday', 0], ['Monday', 1], ['Tuesday', 2],
     ['Wednesday', 3], ['Thursday', 4], ['Friday', 5], ['Saturday', 6]]
  end

  def time_range
    start = 0
    times = []
    while start < 24*3600
      times << [Time.at(start).utc.strftime("%H:%M"), start]
      start += 30*60
    end
    return times
  end

  def allowed_durations
    duration = 15*60
    allowed = []
    while duration <= 4*3600
      allowed << [Time.at(duration).utc.strftime("%H:%M"), duration]
      duration += 15*60
    end
    return allowed
  end

end
