class ResidentController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #paginate 'residents' table
    #@resident_pages, @residents = paginate :residents, :per_page => 10
    @residents = Resident.sort_by_insurance
  end

  def show
    @resident = Resident.find(params[:id])
  end

  def show_by_therapist
    @therapists = Therapist.find(:all)
  end

  def saturdays
    @residents = Resident.for_saturday
  end

  def new
    @resident = Resident.new
    @therapists = Therapist.find(:all).map {|t| [t.name, t.id] }
  end

  def create
    #puts "params = #{params}"
    #therapist_id = params[:therapist][:id]
    #puts "therapist_id = #{therapist_id}"
    @resident = Resident.create(params[:resident])

    #therapist = Therapist.find(:first, therapist_id)
    #@resident.therapists << therapist
    if @resident.save
      flash[:notice] = 'Resident was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @resident = Resident.find(params[:id])
    @therapists = Therapist.find(:all).map {|t| [t.name, t.id] }
  end

  def update
    @resident = Resident.find(params[:id])
    if @resident.update_attributes(params[:resident])
      flash[:notice] = 'Resident was successfully updated.'
      redirect_to :action => 'show', :id => @resident
    else
      render :action => 'edit'
    end
  end

  def destroy
    Resident.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
