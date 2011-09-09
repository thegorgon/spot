class Admin::SessionTestController < Admin::BaseController
  def new
    @value = Nonce.friendly_token
    session[:session_test_value] = @value
    Rails.cache.write("session_test_value", @value, :expires_in => 1.day)
  end
  
  def show
    @session = session[:session_test_value]
    @cache = Rails.cache.read("session_test_value")
  end
end