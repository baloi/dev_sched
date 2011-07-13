require File.dirname(__FILE__) + '/../test_helper'

class CalendarTest < Test::Unit::TestCase
  def test_simple_time
    day = Day.new(2011, 2, 1)
    hour = 8
    min = 30
    t = Time.mktime(day.year, day.month, day.date, hour, min)
    assert_equal t, SimpleTime.eight_thirty_am(day)
  end
end

