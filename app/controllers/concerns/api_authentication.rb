module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    def self.protect_api(**options)
      skip_before_action(:verify_authenticity_token, options)
      options = options.reverse_merge(prepend: false)
      before_action(:verify_tokens, **options)
    end
  end

  private

  EXPECTED_API_AUTHORIZATION_PATTERN =
    /\ABearer +#{Regexp.escape(HaenawaConst::API_TOKEN)}\z/

  INVALID_TOKEN_MESSAGE = 'Bearer realm="api access", error="invalid_token"'

  def api_request?
    'json' == params[:format]
  end

  # urn:ietf:rfc:6750 のトークン検証
  def verify_bearer_token
    if EXPECTED_API_AUTHORIZATION_PATTERN =~ request.authorization
      return
    end

    logger.error("APIトークン不一致:" +
                 " authorization=#{request.authorization.inspect}")
    response.headers['WWW-Authenticate'] = INVALID_TOKEN_MESSAGE
    render body: nil, status: 401
  end

  def verify_tokens
    if api_request?
      verify_bearer_token
    else
      verify_authenticity_token
    end
  end
end
