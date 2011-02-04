class ServiceException < IOError
end

class ExternalServiceException < ServiceException
end