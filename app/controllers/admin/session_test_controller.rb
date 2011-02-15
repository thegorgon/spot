class Admin::SessionTestController < Admin::BaseController
  def new
    @value = Authlogic::Random.friendly_token
    session[:session_test_value] = @value
    Rails.cache.write("session_test_value", @value, :expires => 1.day)
  end
  
  def show
    @session = session[:session_test_value]
    @cache = Rails.cache.read("session_test_value")
  end
end