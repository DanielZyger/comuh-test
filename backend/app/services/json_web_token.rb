class JsonWebToken
  ALGORITHM = "HS256"

  def self.encode(expires_in: 24.hours, **payload)
    payload = payload.merge(exp: expires_in.from_now.to_i)
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    body = JWT.decode(token, secret, true, algorithm: ALGORITHM).first
    ActiveSupport::HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    Rails.application.secret_key_base
  end
end
