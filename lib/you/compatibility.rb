module Ruby
  module You
    VERSION = ::You::VERSION

    Error = ::You::Error
    Configuration = ::You::Configuration
    BadRequestError = ::You::BadRequestError
    UnauthorizedError = ::You::UnauthorizedError
    ForbiddenError = ::You::ForbiddenError
    NotFoundError = ::You::NotFoundError
    UnprocessableEntityError = ::You::UnprocessableEntityError
    RateLimitError = ::You::RateLimitError
    InternalServerError = ::You::InternalServerError
    BadGatewayError = ::You::BadGatewayError
    ServiceUnavailableError = ::You::ServiceUnavailableError
    GatewayTimeoutError = ::You::GatewayTimeoutError
  end
end
