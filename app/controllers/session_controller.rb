# BALOI WORKING
class SessionController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update],
         :redirect_to => { :action => :list }

  def list
    #@session_pages, @sessions = paginate :sessions, :per_page => 10
    @sessions = Session.find(:all)
  end

  def show
    @_session = Session.find(params[:id])
  end

  def new
    @_session = Session.new
    # baloi start
    @rehab_days = RehabDay.find(:all)
    @rehab_days_array = @rehab_days.map {|rehab_day| 
                          [rehab_day.date, rehab_day.id]}
    # current rehab day
    rd_id = request.session[:rehab_day_id]
    cur_rehab_day = RehabDay.find(rd_id.to_i)
    cur_rehab_day_time = cur_rehab_day.to_time
   
    @_session.time_start = cur_rehab_day_time 
    @_session.time_end = cur_rehab_day_time 

    @therapists = Therapist.find(:all).map {|t| [t.name, t.id] }

    # baloi end
  end

  def create
    #therapist = params[:session][:therapist]
    #puts "therapist = >>>#{therapist}<<<}"

    # baloi start
    #puts "type = >>#{params[:session][:type]}<<<"
    @_session = create_class_from_params(params[:session][:type], params[:session])
    @_session.rehab_day_id = request.session[:rehab_day_id]
    #@session.therapist_id = therapist
    # baloi end
    if @_session.save
      flash[:notice] = 'Session was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @_session = Session.find(params[:id])
  end

  def update
    @_session = Session.find(params[:id])
    if @_session.update_attributes(params[:session])
      flash[:notice] = 'Session was successfully updated.'
      redirect_to :action => 'show', :id => @_session
    else
      render :action => 'edit'
    end
  end

  def destroy
    Session.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def add_resident
    #puts ">>>#{request.method.to_s}<<<"
     sess_id = params[:id]
     @_session = Session.find(:first, 
          :conditions => "id = #{sess_id}")

    if request.get?
      #puts ">>>method is get<<<"
      @residents = Resident.find(:all).map {|t| [t.name, t.id] }
      puts response.body
    elsif request.post?
      #puts ">>>method is post<<<"
      #puts ">>> id = #{sess_id}<<<"
      #puts ">>> resident_id = #{resident_id}<<<"
      #resident_id = params[:resident_id]
      resident_id = params[:resident][:id]
      resident = Resident.find(:first,
          :conditions => "id = #{resident_id}")
  
      @_session.residents << resident
      # if session is not a group then check first if it already has residents

      redirect_to :action => 'show', :id => sess_id
    end
  end

  def remove_resident
    sess_id = params[:id]
    resident_id = params[:resident_id]
    @_session = Session.find(:first, 
          :conditions => "id = #{sess_id}")

    if request.get?
      #puts ">>> request is get <<<"
      flash[:notice] = 'Action not allowed'
    elsif request.post?
      #puts ">>> request is post <<<"
      resident_session = ResidentSession.find(:first, 
          :conditions => 
          "resident_id = #{resident_id} AND session_id = #{sess_id}")
      #puts "resident to be removed >> #{resident_session.resident.name}<<<"
      resident_session.destroy

      flash[:notice] = 'Session was successfully updated.'
    end
   
    redirect_to :action => 'show', :id => sess_id
  end
end
