class ProximityPushContext
  attr_reader :near_friends, :uri, :notification_body

  def initialize(near_friends)
    @near_friends = near_friends
    @uri = URI.parse(Rails.configuration.parse_url)
    @notification_body =  {
      where: {}, data: { action: 'com.meeter.Together.PUSH_RECEIVED',  data: {} }
    }
  end

  def send
    req = add_request_body(new_push_request)
    req.body = notification_body.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(req)
  end

  private

  def new_push_request
    request = Net::HTTP::Post.new(@uri.request_uri)
    config = AppConfiguration.new('.parse.yml')

    request['X-Parse-Application-Id'] = config.app_id
    request['X-Parse-REST-API-Key'] = config.api_key
    request['Content-Type'] = 'application/json'
    request
  end

  def aps
    loc_args = []
    loc_args.push(near_friends.first.name)
    loc_args.push(near_friends.count)
    loc_args.push('Publicidad de prueba')
    {
      alert: { 'loc-args' => loc_args, 'loc-key' => 'NEW_NF' },
      badge: 1, sound: 'default'
    }
  end

  def add_request_body(req)
    notification_body[:data][:aps] = aps
    #notification_body[:where][:deviceType] = "ios"
    notification_body[:where][:user_id] = 1
    notification_body[:data][:data][:near_friends] = User.first
    req
  end
end
