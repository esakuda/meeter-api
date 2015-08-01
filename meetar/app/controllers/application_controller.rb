class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def render_ok
  	render json: {status: 200}
  end

	def render_invalid_parameters
  	render json: {status: 403}
  end 

  def render_other_problems
  	render json: {status: 404}
  end  
end
