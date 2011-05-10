require File.dirname(__FILE__) + '/../test_helper'
require 'group_controller'

# Re-raise errors caught by the controller.
class GroupController; def rescue_action(e) raise e end; end

class GroupControllerTest < Test::Unit::TestCase
  fixtures :sessions
  fixtures :therapists
  fixtures :rehab_days

  def setup
    @controller = GroupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = sessions(:first_group).id
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_should_be_able_to_add_resident
    #TODO:
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:groups)
  end


  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
  end

  def test_new
    # rehab_day_id should be set in session variable
    rd_id = rehab_days(:one).id

    @request.session[:rehab_day_id] = rd_id

    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:group)
  end

  def test_create
    # BALOI WORKING ON THIS NOW
    #   ERROR: Therapist expected, got String
    num_groups = Group.count

    rehab_day = RehabDay.find(1)

    time_start = '2011-03-19 10:00:00'
    time_end = '2011-03-19 11:00:00'

    @request.session[:rehab_day_id] = rehab_day.id
    post :create, :group => {:time_start => time_start, :time_end => time_end, :type => "PTGroup"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_groups + 1, Group.count
  end


end
