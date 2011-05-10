require File.dirname(__FILE__) + '/../test_helper'
require 'resident_controller'

# Re-raise errors caught by the controller.
class ResidentController; def rescue_action(e) raise e end; end

class ResidentControllerTest < Test::Unit::TestCase
  fixtures :residents
  fixtures :therapists

  def setup
    @controller = ResidentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = residents(:first).id
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

    resident_name = 'Tobo, Dado'
    resident = Resident.find(
                  :first, 
                  :conditions => ["name = ?",  resident_name])

    # trying to see what the response body is
    #puts "@response.body = >>> #{@response.body}" 
    resident_names_in_html = assert_select("td#resident_#{resident.id}_name")
    #resident_names_in_html.each do |td|
    #  puts td
    #end
  
    assert_equal(true, contains_data(resident_names_in_html, resident_name))
    
    assert_not_nil assigns(:residents)
  end

  def test_show
    get :show, :id => @first_id
    res = Resident.find(@first_id)

    assert_response :success
    assert_template 'show'

    #puts @response.body

    tag_id = "div#resident_#{@first_id}_name"
    resident_names_in_html = assert_select(tag_id)
    assert_equal(true, contains_data(resident_names_in_html, res.name))

    assert_not_nil assigns(:resident)
    assert assigns(:resident).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:resident)
  end

  def test_create
    num_residents = Resident.count

    therapist = PhysicalTherapist.new()
    therapist.name = "baloi"
    therapist.save

    resident_name = 'Tse, Tung' 

    #post :create, :resident => {}
    post :create, :resident => {
                      :name => resident_name, 
                      :pt_minutes_per_day => 60,
                      :ot_minutes_per_day => 70,
                      :pt_days_per_week => 5, 
                      :ot_days_per_week => 5,
                      :active => true,
                      :room => '508', 
                      :insurance => "MedA",
#                  }, :therapist => {:id => therapist.id}
                  :physical_therapist_id => therapist.id
                  }
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_residents + 1, Resident.count
 

    # show newly added resident
    resident = Resident.find(:first,
              :conditions => ["name = ?", resident_name])
  
    assert_equal resident.physical_therapist.name, therapist.name 
    get :show, :id => resident.id 

    assert_response :success
    assert_template 'show'

    #puts @response.body

    tag_id = "resident_#{resident.id}_name"
    #puts "tag_id = #{tag_id}"
    n = find_in_html(@response.body, 'div', tag_id)

    assert_equal(resident_name, n)
    #assert_equal('baloi', resident.therapists.first.name)


    assert_not_nil assigns(:resident)
    assert assigns(:resident).valid?


    # check its details
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:resident)
    assert assigns(:resident).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Resident.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Resident.find(@first_id)
    }
  end
end
