class ShortUrl < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  EXPANDER = 1234567890
  validates :url, :presence => true
  validate :url_validity
  
  def self.shorten(url)
    uri = URI.parse(url) rescue nil
    raise ArgumentError "Invalid URI." unless uri
    uri.host ||= HOSTS[Rails.env]
    uri.scheme ||= "http"
    uri.port ||= 3000 if Rails.env.development?
    short = find_by_url(uri.to_s)
    short ||= new(:url => uri.to_s)
    begin
      short.save!
    rescue ActiveRecord::StatementInvalid => error
      raise error unless error.to_s =~ /Mysql2::Error: Duplicate/
      short = find_by_url(uri.to_s)
    end
    short.shortened    
  end
  
  def self.expand(key)
    shortened = find_by_id(key.base62_decode/EXPANDER)
    if shortened
      shortened.increment(:visits)    
      shortened.url
    end
  end
  
  def shortened(options={})
    options[:host] ||= HOSTS[Rails.env]
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