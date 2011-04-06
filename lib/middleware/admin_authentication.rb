class AdminAuthentication
  def initialize(app)
    @app = app
  end
  
  def call(env)
    env['warden'].authenticate
    if env['warden'].user.try(:admin?)
      @app.call(env)
    else
      [ 302, { 'Location'=> "/" }, [] ]
    end
  end
end