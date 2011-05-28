class TherapistController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@therapist_pages, @therapists = paginate :therapists, :per_page => 10
    @therapists = Therapist.find(:all)
  end

  def show
    @therapist = Therapist.find(params[:id])
  end

  def new
    @therapist = Therapist.new
    @professions = ['PhysicalTherapist', 'OccupationalTherapist']
  end

  def create
    #@therapist = Therapist.new(params[:therapist])
    @therapist = create_class_from_params(params[:therapist][:type], params[:therapist])


    if @therapist.save
      flash[:notice] = 'Therapist was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @therapist = Therapist.find(params[:id])
  end

  def update
    @therapist = Therapist.find(params[:id])
    if @therapist.update_attributes(params[:therapist])
      flash[:notice] = 'Therapist was successfully updated.'
      redirect_to :action => 'show', :id => @therapist
    else
      render :action => 'edit'
    end
  end

  def destroy
    Therapist.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
