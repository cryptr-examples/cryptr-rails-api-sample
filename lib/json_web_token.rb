#frozen_string_literal: true
require 'net/http'
require 'uri'
 
class JsonWebToken
  def self.verify(token)
    puts jwks_hash.count
    token_decode = jwks_hash.map do |kid, key|
      begin
        verify_token_with_key(token, key, kid)
      rescue JWT::VerificationError, JWT::DecodeError => e
        Rails.logger.info "failed with kid #{kid}: #{e}"
        nil
      end
    end
    token_decode.compact.first
  end
  
  def self.verify_token_with_key(token, key, kid)
    decoded = JWT.decode(token, key,
            true,
            algorithms: 'RS256',
            verify_iat: true,
            verify_jti: true,
            iss: issuer,
            verify_iss: true,
            aud: ENV['CRYPTR_AUDIENCE'],
            verify_aud: true)
    payload, header = decoded
    if header["kid"] == kid
      decoded
    end
  end
    def self.jwks_hash
    jwks_raw = Net::HTTP.get jwks_uri
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end
  
  def self.issuer
    "#{ENV['CRYPTR_BASE_URL']}/t/#{ENV['TENANT_DOMAIN']}"
  end
    def self.jwks_uri
    URI("#{issuer}/.well-known")
  end
end