class ScheduleController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @schedules = Schedule.find(:all)
  end

  def show
    @schedule = Schedule.find(params[:id])
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = create_therapist_from_params(params[:schedule][:type], params[:schedule])

    #@session.rehab_day_id = session[:rehab_day_id]


    if @schedule.save
      flash[:notice] = 'Schedule was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
  end

  def update
    @schedule = Schedule.find(params[:id])
    if @schedule.update_attributes(params[:schedule])
      flash[:notice] = 'Schedule was successfully updated.'
      redirect_to :action => 'show', :id => @schedule
    else
      render :action => 'edit'
    end
  end

  def destroy
    Schedule.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
