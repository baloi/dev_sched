require File.dirname(__FILE__) + '/../test_helper'
require 'resident_sessions_controller'

# Re-raise errors caught by the controller.
class ResidentSessionsController; def rescue_action(e) raise e end; end

class ResidentSessionsControllerTest < Test::Unit::TestCase
  fixtures :resident_sessions
  fixtures :sessions
  fixtures :residents

  def setup
    @controller = ResidentSessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
