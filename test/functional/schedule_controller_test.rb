require File.dirname(__FILE__) + '/../test_helper'
require 'schedule_controller'

# Re-raise errors caught by the controller.
class ScheduleController; def rescue_action(e) raise e end; end

class ScheduleControllerTest < Test::Unit::TestCase
  fixtures :schedules
  fixtures :rehab_days

  def setup
    @controller = ScheduleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = schedules(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:schedules)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:schedule)
    assert assigns(:schedule).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:schedule)
  end

  def test_create
    num_schedules = Schedule.count

    post :create, :schedule => {:minutes => 60, :type => 'PTSchedule', :minutes_done => 60, :rehab_day_id => 1, :resident_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_schedules + 1, Schedule.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:schedule)
    assert assigns(:schedule).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Schedule.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Schedule.find(@first_id)
    }
  end
end
