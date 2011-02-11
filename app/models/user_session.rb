class UserSession < Authlogic::Session::Base  
  IPHONE_SECRET = "6d61b823758987744f121d4e9686a25d21909dd0c940c4df4cfe2ea37675ec6537b7f15cc0fafa928d6ac08564b332199692d8275c9f262acbb12c1bf9109103"
  API_NONCE_KEY = :api_nonce
  attr_writer :require_credential_key
  attr_reader :authentication_method, :device
  validate :validate_by_device, :if => :device?
  validate :validate_credential_key, :if => :require_credential_key?
  after_validation :clear_nonce
  
  def self.digest_nonce(nonce=nil)
    nonce ||= controller.session[API_NONCE_KEY]
    Digest::SHA2.hexdigest([IPHONE_SECRET, nonce].join("--"))
  end
  
  def self.generate_nonce
    controller.session[API_NONCE_KEY] = Authlogic::Random.friendly_token
    controller.session[API_NONCE_KEY]
  end
  
  def credentials=(value)
    values = value.is_a?(Array) ? value : [value]
    @credentials = values.first
    if values.first.is_a?(Hash)
      values.first.with_indifferent_access.slice(:device).each do |field, value|
        next if value.blank?
        send("#{field}=", value)
      end
    end
  end
  
  def credentials
    @credentials
  end
    
  def authentication_method=(value)
    @authentication_method = ActiveSupport::StringInquirer.new(value.to_s)
  end
    
  def authenticating_with_password?
    false
  end

  def device?
    device.present?
  end
    
  def require_credential_key?
    !!@require_credential_key
  end
  
  private
  
  def device=(value)
    if value.kind_of?(Hash) && value[:id] &&
      @device = Device.find_or_initialize_by_udid(value[:id])
      @device.attributes = value.except(:id)
    elsif value.kind_of?(Device)
      @device = value
    end
  end
  
  def validate_credential_key
    unless credentials[:key] == self.class.digest_nonce
      errors.add(:credential_key, I18n.t("error_messages.credential_key", :default => "is invalid"))
    end
  end
  
  def validate_by_device
    if @device && @device.save && @device.user
      self.attempted_record = @device.user
      @device.touch(:last_login_at)
    else
      errors.add(:device, I18n.t('error_messages.device', :default => "parameters are not valid"))
    end
  end
  
  def clear_nonce
    controller.session[API_NONCE_KEY] = nil
  end
end