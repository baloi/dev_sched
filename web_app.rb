require File.expand_path(File.dirname(__FILE__)) + '/scheduler'
require File.expand_path(File.dirname(__FILE__)) + '/app_helpers'
require 'sinatra'
require 'haml'

require File.expand_path(File.dirname(__FILE__)) + '/spec/spec_helpers'
include MySpecHelper
include GroupSpecHelper
include SchedulerSpecHelper

#enable :sessions
use Rack::Session::Cookie

#DataMapper.setup :default, 'sqlite:///home/baloi/projects/scheduler/web.db'
#DataMapper.setup :default, "sqlite://#{ENV['HOME']}/projects/scheduler/web.db"
#DataMapper.setup :default, 'sqlite3::memory:'
#DataMapper.auto_migrate!


configure :production do
  enable :sessions
end

helpers do

  def therapist_list_tag(therapists)
    select_tag = 
      "<select name='therapist'>"
    therapists.each do |therapist| 
      select_tag = select_tag + 
        " <option value ='#{therapist.id}'>#{therapist.name}</option>"    
      select_tag = select_tag +
        " </option>"
    end

    select_tag = select_tag + "</select>"
    select_tag
  end


  def session_list_tag(sessions)
    select_tag = 
      "<select name='ses'>"
    sessions.each do |s| 
      select_tag = select_tag + 
        " <option value ='#{s.id}'>#{s.short_description}</option>"    
      select_tag = select_tag +
        " </option>"
    end

    select_tag = select_tag + "</select>"
    select_tag


  end

  def resident_list_tag(residents)
    select_tag = 
      #"%select{:name => 'resident'}\n"
      "<select name='resident'>"
    residents.each do |r| 
      select_tag = select_tag + 
        #" %option{ :value => #{r.id} }= #{r.name}"
        " <option value ='#{r.id}'>#{r.name}</option>"    
      select_tag = select_tag +
        " </option>"
    end

    select_tag = select_tag + "</select>"
    select_tag
  end


end

get '/baloi/create_data' do

  session['current_message'] = 'created conflicting data'
  DataBank.create_initial_residents
  DataBank.create_initial_therapists
  #puts ">>>session, current_message = #{session['current_message']}<<<"
  redirect '/baloi'
end

get '/baloi/create_conflicting_data' do
  delete_all_data
  session['current_message'] = 'created conflicting data'
  DataBank.create_initial_residents
  DataBank.create_initial_therapists

  rd = RehabDay.new()
  rd.set_day(Day.new(2010, 11, 10))

  if rd.save
    session[:day_id] = rd.id
  else
    @errors = []
    @day.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/day/error'
  end

  day = rd.day

  # add sessions including conflicting via database
  resident = Resident.all.first

  tx = normal_treatment(day, resident)
  tx.save.should == true

  #########################
  rd.add_session(tx)
  #########################

  conflicting_tx = conflicting_treatment(day, resident) 
  conflicting_tx.save

  #########################
  rd.add_session(conflicting_tx)
  #########################

  rd.save
  resident2 = Resident.all.last

  late_tx = late_treatment(day, resident2) 
  late_tx.save

  #########################
  rd.add_session(late_tx)
  #########################

  rd.save

  conflicting_late_tx = conflicting_late_treatment(day, resident2) 
  conflicting_late_tx.save

  #########################
  rd.add_session(conflicting_late_tx)
  #########################

  rd.save

  redirect '/baloi'
end

get '/baloi/testing' do
  msg = params[:the_message]
  if msg != nil && msg != ''
    session['current_message'] = msg.strip
  end
  @current_message = session['current_message']
  haml :"baloi/testing"
end

get '/baloi/testing/session' do
  @current_message = session['current_message']
  haml :"baloi/testing_session"
end

get '/baloi' do
  @residents = Resident.all
  @current_message = session['current_message']
  haml :"baloi/index"
end

get '/day/add_session/:rid' do
  @rehab_day = RehabDay.get(params[:rid])
  @sessions = Session.all
  haml :"day/add_session"
end

post '/day/add_session/:rid' do
  @day = RehabDay.get(params[:rid])
  @sessions = Session.all
  sid = params[:ses]
  # session collides with Sinatra "session"
  ses = Session.get(sid)
 
  @day.add_session(ses) 

  if (@day.save)
    link = "/day/show/#{@day.id}" 
    redirect link
  else
    @errors = []
    @day.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end
    redirect '/day/error'
  end

end

get '/day/new' do
  haml :"day/new"
end

post '/day' do
  year = params[:year].strip.to_i
  month = params[:month].strip.to_i
  day = params[:day].strip.to_i

  @rehab_day = RehabDay.new()  
  @rehab_day.set_day(Day.new(year, month, day))

  if @rehab_day.save
    session[:day_id] = @rehab_day.id
    redirect '/day/list'
  else
    @errors = []
    @day.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/day/error'
  end

end

get '/day/show/:id' do
  id = params[:id]
  @rehab_day = RehabDay.get(id) 
  session[:day_id] = id
  haml :"day/show"
end

get '/day' do
  haml :"day/index"
end

get '/day/list' do
  @rehab_days = RehabDay.all
  haml :"day/list"
end

get '/therapist' do
  haml :therapist
end

get '/therapist/:tid/sessions' do

  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  therapist = Therapist.get(params[:tid])

  @therapist = therapist.name
  @conflicts = rehab_day.conflicts
  @treatments = Treatment.all(:therapist => therapist)
  haml :"treatment/list"
end


get '/therapist/list' do
  @therapists = Therapist.all
  haml :therapist_list
end

get '/therapist/new' do
  haml :therapist_new
end

post '/therapist' do
  name = "#{params[:therapist_name].strip}"

  @therapist = Therapist.new(:name => name)  
  @errors = []

  if @therapist.save
    redirect '/therapist/list'
  else
    @therapist.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/therapist/error'
  end
end

get '/resident' do
  haml :"resident/index"
end

post '/resident' do
  name = "#{params[:last_name].strip}, #{params[:first_name].strip}"

  @resident = Resident.new(:name => name)  

  @resident.pt_minutes_per_day = params[:pt_minutes_per_day].strip
  @resident.ot_minutes_per_day = params[:ot_minutes_per_day].strip
  @resident.pt_days_per_week = params[:pt_days_per_week].strip
  @resident.ot_days_per_week = params[:ot_days_per_week].strip

  if @resident.save
    redirect '/resident/list'
  else
    @errors = []
    @resident.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/resident/error'
  end
end

get '/resident/error' do
  haml :resident_error
end

get '/resident/list' do
  @residents = Resident.all
  haml :resident_list
end

get '/resident/new' do
  haml :resident_new
end


get '/resident/:rid/sessions' do
  #"Resident id = #{params[:rid]}"
  @person = Resident.get(params[:rid])
  
  haml :"session/list"
end

get '/' do
  haml :index
end


get '/group' do
  haml :group
end

get '/group/show/:id' do
  @group = Group.get(params[:id])
  if (@group) 
    haml :group_show
  else
    redirect '/group/list'
  end
end

get '/group/add_resident/:gid' do
  @group = Group.get(params[:gid])
  @residents = Resident.all
  haml :group_add_resident
end


post '/group/add_resident/:gid' do
  @group = Group.get(params[:gid])
  @residents = Resident.all
  r_id = params[:resident]
  resident = Resident.get(r_id)
 
  @group.residents << resident

  if (@group.save)
    link = "/group/show/#{@group.id}" 
    redirect link
  else
    @errors = []
    @group.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end
    redirect '/group/error'
  end

end

post '/group' do
  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  day = rehab_day.day

  time_start = params[:time_start].strip
  time_end = params[:time_end].strip
  
  time_start = Calendar.create_day_time(day, time_start)
  time_end = Calendar.create_day_time(day, time_end)

  therapist = Therapist.get(params[:therapist].to_i)
  group_type = params[:session_type].strip

  if group_type == "PT"
    @group = PTGroup.new  
  else
    @group = OTGroup.new  
  end

  rehab_day.sessions << @group

  @group.time_start = time_start
  @group.time_end = time_end
  @group.therapist = therapist

  if @group.save
    redirect '/group/list'
  else
    @errors = []
    @group.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/group/error'
  end
end

get '/group/error' do
  haml :group_error
end

get '/group/list' do
  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)

  @groups = Group.all(:rehab_day => rehab_day)
  haml :group_list
end

get '/group/new' do
  @therapists = Therapist.all
  haml :group_new
end


get '/schedule' do
  haml :schedule
end

get '/schedule/new' do
  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  @date = "#{rehab_day.year}/#{rehab_day.month}/#{rehab_day.day_of_month}"
 
  haml :schedule_new
end

get '/schedule/list' do
  #@rehab_day = RehabDay.all.first
  day_id = session[:day_id]
  @rehab_day = RehabDay.get(day_id)
  haml :schedule_list
end

post '/schedule' do
  #@rehab_day = RehabDay.new()
  #@rehab_day.set_day(Day.new(year, month, day))
  day_id = session[:day_id]
  @rehab_day = RehabDay.get(day_id)

  scheduler =  Scheduler.new 

  #puts ">>>rehab_day = #{@rehab_day}<<<"
  scheduler.create_day_schedules(@rehab_day)

  if @rehab_day.save
    redirect '/schedule/list'
  else
    @errors = []
    @rehab_day.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/schedule/error'
  end
end

get '/treatment' do
  haml :"treatment/index"
end

get '/treatment/list' do
  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  
  @therapist = "all"
  @conflicts = rehab_day.conflicts.all
  @treatments = Treatment.all(:rehab_day => rehab_day)

  DataUtils.flush_conflicts(rehab_day)

  haml :"treatment/list"
end

get '/treatment/new' do
  @therapists = Therapist.all
  @residents = Resident.all
  haml :"treatment/new"
end

get '/treatment/conflicting' do
  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  @therapist = "all"
  @treatments = Treatment.all
 
  #puts ">>> conflict length = #{rehab_day.conflicts.length} <<<"
  #puts ">>> conflict 1, description = #{rehab_day.conflicts.all.first.description} <<<"
  #puts ">>> conflict 2, description = #{rehab_day.conflicts.all.last.description} <<<"
  
  @conflicts = rehab_day.conflicts.all

  DataUtils.flush_conflicts(rehab_day)

  #@conflicts.each do |c|
  #  puts ">>> a conflict description -- #{c.description}"
  #end
  haml :"treatment/conflicting"
end

post '/treatment' do

  # from saving manually...
  #  treatment = PTTreatment.new
  #  treatment.time_start = SimpleTime.ten_thirty_am(day) 
  #  treatment.time_end = SimpleTime.eleven_fifteen_am(day) 
  #  resident.sessions << treatment
  #  resident.save
  #  rd.add_session(treatment)

  day_id = session[:day_id]
  rehab_day = RehabDay.get(day_id)
  day = rehab_day.day

  time_start = params[:time_start].strip
  time_end = params[:time_end].strip
  
  time_start = Calendar.create_day_time(day, time_start)
  time_end = Calendar.create_day_time(day, time_end)

  therapist = Therapist.get(params[:therapist].to_i)
  resident = Resident.get(params[:resident].to_i)
  treatment_type = params[:treatment_type].strip

  @treatment = nil

  if treatment_type == "PT"
    @treatment = PTTreatment.new  
  else
    @treatment = OTTreatment.new  
  end

  @treatment.time_start = time_start
  @treatment.time_end = time_end
  @treatment.therapist = therapist
  #@treatment.residents << resident
  resident.sessions << @treatment
  resident.save

  if @treatment.save
    #puts "treatment saved"
    treatment_saved = true
  else
    @errors = []
    @treatment.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/treatment/error'
  end

  rehab_day.add_session(@treatment)

  if rehab_day.save
    redirect '/treatment/list'
  else
    @errors = []
    rehab_day.errors.each do |e|
      @errors << e
      puts ">>>#{e}<<<"
    end

    redirect '/treatment/error'
  end

end
