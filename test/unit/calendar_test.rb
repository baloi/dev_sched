require File.dirname(__FILE__) + '/../test_helper'

class CalendarTest < Test::Unit::TestCase
  def test_simple_time
    day = Day.new(2011, 2, 1)
    hour = 8
    min = 30
    t = Time.mktime(day.year, day.month, day.date, hour, min)
    assert_equal t, SimpleTime.eight_thirty_am(day)

    day = Day.new(2011, 2, 1)
    hour = 9
    min = 0
    t = Time.mktime(day.year, day.month, day.date, hour, min)
    assert_equal t, SimpleTime.nine_o_clock_am(day)

  end

  def test_create_day
    day = Day.new(2011, 2, 1)
    day_time = Calendar.create_day_time(day, "9:00")
    t = Time.mktime(day.year, day.month, day.date, 9)
    assert_equal t, day_time
  end

private
  def create_day
  end
end

