# BALOI WORKED
require File.dirname(__FILE__) + '/../test_helper'
require 'rehab_day_controller'

# Re-raise errors caught by the controller.
class RehabDayController; def rescue_action(e) raise e end; end

class RehabDayControllerTest < Test::Unit::TestCase
  fixtures :rehab_days

  def setup
    @controller = RehabDayController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @one_id = rehab_days(:one).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_select_rehab_day
    
    get :set_day, :id => @one_id
    rd = rehab_days(:one)

    #post :create, :rehab_day => {:year => 2011, :month => 2, :day_of_month => 10}
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal rd.id, @request.session[:rehab_day_id].to_i

  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:rehab_days)
  end

  def test_show
    get :show, :id => @one_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:rehab_day)
    assert assigns(:rehab_day).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:rehab_day)
  end

  def test_create
    num_rehab_days = RehabDay.count

    post :create, :rehab_day => {:year => 2011, :month => 2, :day_of_month => 10}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_rehab_days + 1, RehabDay.count
  end

  def test_edit
    get :edit, :id => @one_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:rehab_day)
    assert assigns(:rehab_day).valid?
  end

  def test_update
    post :update, :id => @one_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @one_id
  end

  def test_destroy
    assert_nothing_raised {
      RehabDay.find(@one_id)
    }

    post :destroy, :id => @one_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      RehabDay.find(@one_id)
    }
  end
end
