# calendar.rb

# represents a calendar
require 'date'

module SimpleTime
  
  def SimpleTime.eight_thirty_am(day)
    Calendar.create_day_time(day, "8:30")
  end

  def SimpleTime.nine_o_clock_am(day)
    Calendar.create_day_time(day, "9:00")
  end

  def SimpleTime.nine_thirty_am(day)
    Calendar.create_day_time(day, "9:30")
  end

  def SimpleTime.ten_o_clock_am(day)
    Calendar.create_day_time(day, "10:00")
  end

  def SimpleTime.ten_fifteen_am(day)
    Calendar.create_day_time(day, "10:15")
  end


  def SimpleTime.ten_thirty_am(day)
    Calendar.create_day_time(day, "10:30")
  end

  def SimpleTime.ten_forty_five_am(day)
    Calendar.create_day_time(day, "10:45")
  end

  def SimpleTime.eleven_o_clock_am(day)
    Calendar.create_day_time(day, "11:00")
  end

  def SimpleTime.eleven_fifteen_am(day)
    Calendar.create_day_time(day, "11:15")
  end


  def SimpleTime.eleven_thirty_am(day)
    Calendar.create_day_time(day, "11:30")
  end


  def SimpleTime.twleve_o_clock_pm(day)
    Calendar.create_day_time(day, "12:00")
  end



end

module Calendar

  def Calendar.create_day_time(day, time)
    hm = time.split(':')

    year = day.year
    month = day.month
    day = day.date
    hour = hm[0]
    minute = hm[1]

    Time.mktime(year, month, day, hour, minute)

  end

  def Calendar.is_valid_month_number?(mo)
    #return false if mo.to_i == 0
    month_range = 1..31
    month_list = month_range.to_a
    #puts "<<< month_list = #{month_list}"
    #puts "<<< mo = #{mo}"
    month_list.grep(mo).length == 1
  end

  def Calendar.is_date_string?(str)
    ymd = /(19|20)[0-9]{2}[- \/.](0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])/
    #dd = /([0-2]?[1-9]|[1-3][01])/
    str.match(ymd) != nil
  end

  def Calendar.day_from_date(date)
    date_array = Calendar.date_to_int_array(date)
    #puts ">>> day_array = #{date_array}"
    date_array[2]
  end

  def Calendar.date_string(year, month, day)
    date = Date.new(year, month, day)

    day_string = date.strftime("%Y/%m/%d")
  end 

  def Calendar.next_day(day)
    date_in_num_array = Calendar.date_to_int_array(day)

    d = Date.new(date_in_num_array[0], date_in_num_array[1], date_in_num_array[2])
    next_day = d.next()

    next_day_string = next_day.strftime("%Y/%m/%d")
  end

  def Calendar.date_to_int_array(date)
    int_array = [] 
    arr = date.split("/")
    int_array << arr[0].to_i
    int_array << arr[1].to_i
    int_array << arr[2].to_i

    int_array
  end

  def Calendar.date?(d)
    dd = /([0-2]?[1-9]|[1-3][01])/
    d.match(dd) != nil
  end

  def Calendar.month(month_name)
    month_hash = {"jan" => 1, "feb" => 2, "mar" => 3, "apr" => 4, "may" => 5, 
      "jun" => 6, "jul" => 7, "aug" => 8, "sep" => 9, "oct" => 10, "nov" => 11, 
      "dec" => 12, }
    return month_hash[month_name]
  end

  def Calendar.wdays
    ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
  end
  def Calendar.create_month(year, month)
    Month.new(year, month)
  end

  def Calendar.create_day(year, month, day)
    new_day = Day.new(year, month, day)
  end
  module Entries
    def Entries.is_date_entry?(entry)
      date_array = entry.split "/"
      year = date_array[0]

      month = Calendar.month(date_array[1]).to_i
      return false if Calendar.is_valid_month_number?(month) == false
      return false if month == nil

      month = month.to_s
      if month.length == 1
        month = "0" + month
      end

      day = date_array[2]
      return false if day == 0
      return false if Calendar.date?(day) != true

      date_string = "#{year}/#{month}/#{day}"
      Calendar.is_date_string?(date_string)
    end

    def Entries.find_entry(entries, date)
      #puts ">>> date = #{date}"
      #puts ">>> entries = #{entries}"
      entry = nil
      entries.each do |ent|
      if Calendar::Entries.is_date_entry?(ent.full_name)
        converted = Calendar::Entries.convert_to_date(ent.full_name) 
          if converted  == date
            entry = ent
          end
        end
      end
      entry
    end

    def Entries.convert_to_date(entry_name)
      date_array = entry_name.split "/"
      year = date_array[0].to_i
      month = Calendar.month(date_array[1]).to_i
      day = date_array[2].to_i

      Calendar.date_string(year, month, day)
    end

    def Entries.extract_dates(entries)

      dates = []
      entries.each do |entry|
        name = entry.full_name
        day_array = name.split "/"
        entry_day = day_array[2]

        ##@@ if Calendar::Entries.is_date_entry?(name)

        if Calendar.date?(entry_day)

          #puts ">>> name = #{name}, converted = #{converted}"
          #date = entry_day.to_i
          date = Entries.convert_to_date(name)
          dates << date
        end
      end
    dates
  end

  end
end

# a month class
class Month
  attr_reader :year, :month, :weeks
  def initialize(year, month)
    # each month as a number of weeks
    @year = year
    @month = month

    day_range = 1..last_day
    @day_list = day_range.to_a

    @weeks = get_weeks(@year, @month, @day_list)
  end

  def get_day(day_of_month)
    # search for day 

    day = get_day_from_weeks(day_of_month, @weeks)

  end

  def get_day_from_weeks(day_of_month, weeks_of_month)
    day = nil
    weeks_of_month.each do |week|
      week.days.each do |cur_day|
        if cur_day != nil and cur_day.date == day_of_month 
          day = cur_day
        end
      end
    end
    day
  end

  def cal_month
    @month
  end


  def number_of_weeks
    @weeks.length
  end


  def last_day
      mdays = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      mdays[2] = 29 if Date.leap?(@year)
      mdays[@month]
  end


  protected
  def create_day(year, month, day)
    dayObj = Calendar.create_day(year, month, day)
    dayObj
  end

  private
  # returns the weeks for the month
  def get_weeks(year, month, list_of_days)
    weeks = Array.new
    
    day_list = list_of_days.dup

    weeks[0] = first_week(year, month, day_list)

    nweeks = day_list.size/7 + 1
    
    nweeks.times do |i|
      new_week = Week.new(year, month, i+2) 
      7.times do
        break if day_list.empty?
        #new_week.days << day_list.shift  
        #day = Calendar.create_day(year, month, day_list.shift)
        day = create_day(year, month, day_list.shift)
        new_week.days << day  
      end
      weeks[i+1] = new_week
    end

    # pad first week
    pad_first = 7 - weeks[0].days.size
    pad_first.times { weeks[0].days.unshift(nil) }

    # pad last week
    pad_last = 7 - weeks[-1].days.size
    pad_last.times { weeks[-1].days << nil }    

    weeks

  end

  def first_week(year, month, day_list)
    # get first day of month
    t = Time.mktime(year, month, 1)

    # get the day of week for the first day of the month
    first = t.wday

    days_in_first_week = 7 - first

    week = Week.new(year, month, 1) 

    days_in_first_week.times do
      #week.days << day_list.shift
      day = Calendar.create_day(year, month, day_list.shift)
      week.days << day
    end

    week
  end
end

class Week
  attr_reader :year, :month, :week_of_month, :days
  def initialize(year, month, week_of_month)
    @year = year
    @month = month
    @week_of_month = week_of_month
    @days = Array.new
  end

end

class Item
  attr_accessor :kind, :amount, :date, :description

  def is_expense?
    return @amount < 0
  end

  def is_earning?
    return @amount > 0
  end
end

class Day

  attr_reader :year, :month, :date, :day_of_week, :items
  
  # +year+ is calendar year
  # +month+ calendar month (1-12)
  # +day+ day of week (0-6)
  def initialize(year, month, day)
    @year = year
    @month = month
    @date = day

    t = Time.mktime(@year, @month, day)
    @day_of_week = Calendar.wdays[t.wday]
    @items = []
  end

  def has_items
    @items.length > 0
  end
end
