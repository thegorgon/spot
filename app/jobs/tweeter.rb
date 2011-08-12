module Jobs
  class Tweeter
    @queue = :processing
    
    def self.perform(tweet)
      global_account = TWITTER_SETTINGS['accounts']['wishlistitems']
      Twitter.oauth_token = global_account['oauth_token']
      Twitter.oauth_token_secret = global_account['oauth_token_secret']
      begin
        Twitter.update tweet if tweet && Rails.env.production?
        true
      rescue Twitter::Forbidden => e
        false
      end
    end
    
  end
end