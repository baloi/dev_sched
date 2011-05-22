# BALOI WORKING NOW
class GroupController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update, :add_resident ],
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@group_pages, @groups = paginate :groups, :per_page => 10
    #@groups = Group.find(:all)
    @groups = Session.find_all_groups
  end

  def show
    @group = Session.find(params[:id])
  end

  def new
    @group = Group.new
    # baloi start
    # current rehab day
    rd_id = session[:rehab_day_id]
    cur_rehab_day = RehabDay.find(rd_id.to_i)
    cur_rehab_day_time = cur_rehab_day.to_time
   
    @group.time_start = cur_rehab_day_time 
    @group.time_end = cur_rehab_day_time 

    @therapists = Therapist.find(:all).map {|t| [t.name, t.id] }

    # baloi end
  end


  def create

    # baloi start
    #puts "type = >>#{params[:group][:type]}<<<"
    @group = create_class_from_params(params[:group][:type], params[:group])
    @group.rehab_day_id = session[:rehab_day_id]
    # baloi end
    if @group.save
      flash[:notice] = 'Groups was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Session.find(params[:id])
  end

  def update
    @group = Session.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'edit'
    end
  end

#  def add_resident
#
#    if (request.get?) 
#      puts "get request"
#      puts ">>>:id = #{params[:id]}<<<"
#      #get '/group/add_resident/:gid' do
#      #  @group = Group.get(params[:gid])
#      #  @residents = Resident.all
#      #  haml :group_add_resident
#      #end
#   
#    elsif (request.post?)
#      puts "post request"
#      puts ">>>:id = #{params[:id]}<<<"
#      #puts ">>>request contents = #{request}<<<"
#      #link = "/group/show/#{@group.id}" 
#
#      render :action => "show", :id => "#{params[:id]}"
#
#  
#      #post '/group/add_resident/:gid' do
#      #  @group = Group.get(params[:gid])
#      #  @residents = Resident.all
#      #  r_id = params[:resident]
#      #  resident = Resident.get(r_id)
#      # 
#      #  @group.residents << resident
#      #
#      #  if (@group.save)
#      #    link = "/group/show/#{@group.id}" 
#      #    redirect link
#      #  else
#      #    @errors = []
#      #    @group.errors.each do |e|
#      #      @errors << e
#      #      puts ">>>#{e}<<<"
#      #    end
#      #    redirect '/group/error'
#      #  end
#      #end
#
#    else
#      puts "unknown request"
#      #render :action => "/group/show/#{''}"
#    end
#  end

end
