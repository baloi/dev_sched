require File.dirname(__FILE__) + '/../test_helper'
require 'session_controller'
require 'calendar'

# Re-raise errors caught by the controller.
class SessionController; def rescue_action(e) raise e end; end

class SessionControllerTest < Test::Unit::TestCase
  fixtures :sessions
  fixtures :rehab_days
  fixtures :therapists

  def setup
    @controller = SessionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    #@first_id = sessions(:first).id
    @first_id = sessions(:simple_session).id

  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
    #puts "response.body = #{@response.body}"
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:sessions)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:session)
    assert assigns(:session).valid?
  end

  def test_new
    set_rehab_day(rehab_days(:one))

    get :new

    assert_response :success
    assert_template 'new'

    #assert_not_nil assigns(:session)
  end

  def test_should_have_default_date_as_rehab_day_date
    # rehab_day should be set in session variable
    set_rehab_day(rehab_days(:one))

    get :new

    #puts ">>>#{@response.body}<<<"
    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:session)
  end


  def test_create
    num_sessions = Session.count

    rehab_day = RehabDay.find(1)

    time_start = '2011-03-19 10:00:00'
    time_end = '2011-03-19 11:00:00'

    set_rehab_day(rehab_day)
    post :create, :session => {:time_start => time_start, :time_end => time_end, :type => "PTTreatment"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_sessions + 1, Session.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:session)
    assert assigns(:session).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Session.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Session.find(@first_id)
    }
  end

  def test_add_resident_GET

    sess_id = sessions(:first_group).id

    get :add_resident, :id => sess_id
    #post :add_resident, :id => sess_id

    #puts ">>>#{@response.body}<<<"
    assert_response :success
    assert_template 'add_resident'

    #assert_not_nil assigns(:session)
  end

  def test_add_resident_POST
    # create new session

    ses = Session.find(:all, :conditions => "description = 'PTGroup'") 
    assert_equal 1, ses.length
    ses = ses[0]
    session_id = ses.id

    assert_equal 0, ses.residents.count
    # create or get resident from fixture and save its id
    resident = Resident.create(:name => 'Glee, Tester')

    # add resident to session/add_resident/:sess_id (put resident.id in post)
    post :add_resident, :id => session_id, :resident => {:id => resident.id} 

    # check if resident is in session
    assert_equal 1, ses.residents.count

    # check resident contained in the Session
    resident_added = ses.residents.first
    assert_equal resident.name, resident_added.name

    assert_response :redirect
    assert_redirected_to :action => 'show'

  end

  def test_remove_resident
    ses = Session.find(:all, :conditions => "description = 'PTGroup'") 
    ses = ses[0]
    ses_id = ses.id

    assert_equal 0, ses.residents.count
    # create or get resident from fixture and save its id
    resident = Resident.create(:name => 'Glee, Tester')
    post :add_resident, :id => ses_id, :resident => {:id => resident.id} 
    assert_equal 1, ses.residents.count
    assert_equal ses.residents[0].name, resident.name

    post :remove_resident, :id => ses_id, :resident_id => resident.id
    assert_equal 0, ses.residents.count
  end

  def test_should_not_be_able_to_remove_resident_from_GET
    ses = Session.find(:all, :conditions => "description = 'PTGroup'") 
    ses = ses[0]
    ses_id = ses.id

    assert_equal 0, ses.residents.count
    # create or get resident from fixture and save its id
    resident = Resident.create(:name => 'Glee, Tester')
    post :add_resident, :id => ses_id, :resident => {:id => resident.id} 
    assert_equal 1, ses.residents.count
    assert_equal ses.residents[0].name, resident.name

    get :remove_resident, :id => ses_id, :resident_id => resident.id
    assert_equal 1, ses.residents.count
    assert_equal ses.residents[0].name, resident.name

    assert_response :redirect
    assert_redirected_to :action => 'show'

  end

end
