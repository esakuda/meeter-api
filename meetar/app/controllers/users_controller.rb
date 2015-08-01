class UsersController < ApplicationController
  #ojo!! ver de sacar esto despues!!!
  skip_before_action :verify_authenticity_token

  def login
  	render_invalid_parameters and return if params[:token].blank? || params[:name].blank? 
  	@user = User.find_by(name: params[:name])
  	
  	@user = User.create(name: params[:name], token: params[:token]) if @user.nil?
  	
		if @user.token.blank?
			@user.update(token: params[:token])
			render_ok and return
		end
		render_ok and return if @user.token.eql?(params[:token])
		render_other_problems and return
		

  end

	def logout
  	render_invalid_parameters and return if params[:token].blank? || params[:name].blank? 
  	@user = User.find_by(name: params[:name])
  	
  	render_invalid_parameters if @user.nil?
  	
		if @user.token.eql?(params[:token])
			@user.update(token: nil)
			render_ok and return 
		else
			render_other_problems and return
		end
  end  

  def update_position
   	render_invalid_parameters and return unless validate_parameters?
   	@user = User.find_by(name: params[:name])
   	if @user.token.eql?(params[:token])
			@user.update(latitude: params[:latitude],longitude: params[:longitude])
			render_ok and return 
		else
			render_other_problems and return
		end
  end

  def validate_parameters?
  	empty_parameters = (params[:name].blank? || params[:token].blank? || params[:latitude].blank? || params[:longitude].blank?) 
  	valid_types = (float?(params[:latitude]) && float?(params[:longitude]))
  	return !empty_parameters && valid_types
  end

  def float? object
  	!!Float(object) rescue false
	end
end