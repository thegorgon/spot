class ShortUrl < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  EXPANDER = 1234567890
  DEFAULT_HOST = Rails.env.production?? "www.spot-app.com" : "www.rails.local"
  validates :url, :presence => true
  validate :url_validity
  
  def self.shorten(url)
    uri = URI.parse(url) rescue nil
    raise ArgumentError "Invalid URI." unless uri
    uri.host ||= DEFAULT_HOST
    uri.scheme ||= "http"
    uri.port ||= 3000 if Rails.env.development?
    find_or_create_by_url(uri.to_s).shortened
  end
  
  def self.expand(key)
    shortened = find_by_id(key.base62_decode/EXPANDER)
    if shortened
      shortened.increment(:visits)    
      shortened.url
    end
  end
  
  def shortened(options={})
    options[:host] ||= DEFAULT_HOST
    options[:port] ||= 3000 if Rails.env.development?
    options[:protocol] ||= "https" if Rails.env.production?
    short_url(key, options)
  end
  
  def key
    (id * EXPANDER).base62_encode
  end
    
  private
  
  def url_validity
    uri = URI.parse(url) rescue nil
    errors.add(:url, 'The format of the url is not valid.') unless uri
  end
end