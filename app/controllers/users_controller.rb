class UsersController < ApplicationController
  #ojo!! ver de sacar esto despues!!!
  skip_before_action :verify_authenticity_token

  def login
  	render_invalid_parameters and return if params[:token].blank? || params[:name].blank? 
  	@user = User.find_by(name: params[:name])
  	byebug
  	if @user.nil?
  		byebug
  		@user = User.create(name: params[:name], token: params[:token])
  		get_friends(@user)
  	end
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
  	render_invalid_parameters and return if @user.nil?
  	
		if @user.token.eql?(params[:token])
			@user.update(token: nil)
			render_ok and return 
		else
			render_other_problems and return
		end
  end  

  def update_position
  	byebug
   	render_invalid_parameters and return unless validate_parameters?
   	@user = User.find_by(token: params[:token])
    byebug
   	if !@user.blank?
			byebug
			@user.update(latitude: params[:latitude],longitude: params[:longitude])
			friends = filter_friends(@user, params[:latitude_min], params[:latitude_max], params[:longitude_min], params[:longitude_max])
			byebug
			ProximityPushContext.new(friends).send if friends.count>0
			#render json: friends and return
			render_ok and return 
		else
			byebug
			render_other_problems and return
		end

  end

  def get_friends(user) 
  	#render_invalid_parameters and return if params[:token].blank? || params[:name].blank? 
  	#@user = User.find_by(name: params[:name])
  	#render_invalid_parameters and return if @user.nil?
		
		@graph = Koala::Facebook::API.new(@user.token)
		
  	friends = @graph.get_connections("me", "friends")
  	friends = friends.map {|f| f["name"]} 
  	logged_friends = User.where(name: friends)
  	logged_friends.each do |f|
  		@user.friendships.create(friend_id: f.id)
  	end
  end

  def filter_friends(user, latitude_min, latitude_max, longitude_min, longitude_max) 
  	answer = []
  	user.friends.each do |f| 
  		answer.push(f) if neighbour?(f, latitude_min.to_f, latitude_max.to_f, longitude_min.to_f, longitude_max.to_f)
  	end
  	answer
  end

  def neighbour?(friend, latitude_min, latitude_max, longitude_min, longitude_max)
  	return false if friend.latitude.blank? || friend.longitude.blank?
  	lat = friend.latitude
  	long = friend.longitude
  	if latitude_min<= latitude_max
  		return latitude_min <= lat && lat <= latitude_max && longitude_min <= long && long <= longitude_max
  	else 
  		return latitude_min <= lat && lat <= latitude_max && longitude_min <= long && long >= longitude_max
  	end
  	#return Math.sqrt((user.latitude - friend.latitude)**2 + (user.longitude - friend.longitude)**2) <= ratio
  end

  def validate_parameters?
  	empty_parameters = (params[:token].blank? || params[:latitude].blank? || params[:longitude].blank? || params[:latitude_min].blank? || params[:latitude_max].blank? || params[:longitude_min].blank? || params[:longitude_max].blank? ) 
  	valid_types = (float?(params[:latitude]) && float?(params[:longitude]) && float?(params[:longitude_min]) && float?(params[:longitude_max]) && float?(params[:latitude_min]) && float?(params[:latitude_max]))
  	return !empty_parameters && valid_types
  end

  def float? object
  	!!Float(object) rescue false
	end
end