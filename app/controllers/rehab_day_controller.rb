class RehabDayController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @rehab_day_pages, @rehab_days = paginate :rehab_days, :per_page => 10
  end

  def show
    @rehab_day = RehabDay.find(params[:id])
  end

  def new
    @rehab_day = RehabDay.new
  end

  def choose
    @rehab_days = RehabDay.find(:all)
  end

  def set_day
      #puts ">>> setting rehab_day_id to #{params[:id]}<<<"
      session[:rehab_day_id] = params[:id]
      flash[:notice] = "'RehabDay id set to  '#{params[:id]}'."
      redirect_to :action => 'list'
   
  end

  def create
    @rehab_day = RehabDay.new(params[:rehab_day])
    if @rehab_day.save
      # baloi start
      session[:rehab_day_id] = @rehab_day.id
      # baloi end
      flash[:notice] = 'RehabDay was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @rehab_day = RehabDay.find(params[:id])
  end

  def update
    @rehab_day = RehabDay.find(params[:id])
    if @rehab_day.update_attributes(params[:rehab_day])
      flash[:notice] = 'RehabDay was successfully updated.'
      redirect_to :action => 'show', :id => @rehab_day
    else
      render :action => 'edit'
    end
  end

  def destroy
    RehabDay.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
