# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rails-branch_session_id'

  def create_class_from_params(obj_class_name, parameters) 
    obj_class = Object.const_get(obj_class_name)
    #puts "session type = >>>> #{session_type}<<<"
    new_obj = obj_class.new(parameters)
  end

end
