class ServiceError < IOError; end

class ExternalServiceError < ServiceError; end

class UnauthorizedAccessError < IOError; end