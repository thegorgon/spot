module NotifiableError
  def notifiable?
    true
  end
end

module NotNotifiableError
  def notifiable?
    false
  end
end

class ServiceError < IOError; end

class ExternalServiceError < ServiceError; end

class UnauthorizedAccessError < IOError; end

class DuplicateConstantError < StandardError; end

Exception.send(:include, NotifiableError)

[ UnauthorizedAccessError, 
  ActiveRecord::RecordNotUnique, 
  ActiveRecord::RecordInvalid, 
  ActiveRecord::RecordNotFound ].each do |error|
  error.send(:include, NotNotifiableError)
end
