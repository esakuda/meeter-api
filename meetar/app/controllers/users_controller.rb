class UsersController < ApplicationController
  #ojo!! ver de sacar esto despues!!!
  skip_before_action :verify_authenticity_token

  def login
  	render json: {status: 403} and return if params[:token].blank? || params[:name].blank? 
  	@user = User.find_by(name: params[:name])
  	
  	@user = User.create(name: params[:name], token: params[:token]) if @user.nil?
  	
		if @user.token.blank?
			@user.update(token: params[:token])
			render json: {status: 200} and return
		end
		render json: {status: 200} and return if @user.token.eql?(params[:token])
		render json: {status: 404} and return
		
		
  end

	def logout
  	render json: {status: 403} and return if params[:token].blank? || params[:name].blank? 
  	@user = User.find_by(name: params[:name])
  	
  	render json: {status:403} if @user.nil?
  	
		if @user.token.eql?(params[:token])
			@user.update(token: nil)
			render json: {status: 200} and return 
		else
			render json: {status: 404} and return
		end
  end  

  def update_position

  end
end