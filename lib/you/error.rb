module You
  class Error < StandardError; end

  class BadRequestError < Error; end          # 400

  class UnauthorizedError < Error; end        # 401

  class ForbiddenError < Error; end           # 403

  class NotFoundError < Error; end            # 404

  class UnprocessableEntityError < Error; end # 422

  class RateLimitError < Error; end           # 429

  class InternalServerError < Error; end      # 500

  class BadGatewayError < Error; end          # 502

  class ServiceUnavailableError < Error; end  # 503

  class GatewayTimeoutError < Error; end      # 504
end
