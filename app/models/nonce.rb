class Nonce
  IPHONE_SECRET = "6d61b823758987744f121d4e9686a25d21909dd0c940c4df4cfe2ea37675ec6537b7f15cc0fafa928d6ac08564b332199692d8275c9f262acbb12c1bf9109103"
  SESSION_KEY = :api_nonce
  FRIENDLY_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  
  def self.digest(nonce=nil)
    Digest::SHA2.hexdigest([IPHONE_SECRET, nonce].join("--"))
  end
    
  def self.friendly_token
    newpass = ""
    1.upto(20) { |i| newpass << FRIENDLY_CHARS[rand(FRIENDLY_CHARS.size-1)] }
    newpass
  end
  
  def self.hex_token
    digest = Time.now.to_s + (1..10).collect{ rand.to_s }.join
    20.times { digest = Digest::SHA512.hexdigest(digest) }
    digest
  end
  
  def initialize(params={})
    @session = params[:session]
    @token = params[:token]
    generate!
  end

  def generate!
    @token ||= @session[SESSION_KEY] if @session
    @token ||= self.class.friendly_token
    @session[SESSION_KEY] = @token if @session
  end

  def token
    generate! unless @token
    @token
  end
  
  def digested
    self.class.digest(token)
  end
    
  def clear
    @token = nil
    @session[SESSION_KEY] = nil if @session
  end        
end