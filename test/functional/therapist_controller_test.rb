require File.dirname(__FILE__) + '/../test_helper'
require 'therapist_controller'

# Re-raise errors caught by the controller.
class TherapistController; def rescue_action(e) raise e end; end

class TherapistControllerTest < Test::Unit::TestCase
  fixtures :therapists

  def setup
    @controller = TherapistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @one_id = therapists(:one).id
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

    assert_not_nil assigns(:therapists)
  end

  def test_show
    get :show, :id => @one_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:therapist)
    assert assigns(:therapist).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:therapist)
  end

  def test_create
    num_therapists = Therapist.count

    post :create, :therapist => {:name => 'Janjan', :type => "PhysicalTherapist"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_therapists + 1, Therapist.count
  end

  def test_edit
    get :edit, :id => @one_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:therapist)
    assert assigns(:therapist).valid?
  end

  def test_update
    post :update, :id => @one_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @one_id
  end

  def test_destroy
    assert_nothing_raised {
      Therapist.find(@one_id)
    }

    post :destroy, :id => @one_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Therapist.find(@one_id)
    }
  end
end
