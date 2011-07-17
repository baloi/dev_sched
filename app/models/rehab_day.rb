class RehabDay < ActiveRecord::Base
  has_many :sessions
  has_many :caseloads  

  def date
    "#{self.year}/#{self.month}/#{self.day_of_month}"
  end

  def set_day(day)
    @day = day
    # Attributes of Day class:
    # :year, :month, :date, :day_of_week, :items

    self.year = day.year
    self.month = day.month
    self.day_of_month = day.date
    #puts "#>>> @year = #{@year}"
  end

  def to_time
    Time.mktime(self.year, self.month, self.day_of_month)
  end

  def day
    if @day == nil
      @day = Day.new(@year, @month, @day_of_month)
    end

    @day
  end

end
