module JwtToken
  
  SECRET_KEY = ENV['DEVISE_JWT_SECRET_KEY']
  ALGORITHM = 'HS256'

  def self.generate(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    payload[:iat] = Time.now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.verify(token)
    return nil if token.blank?
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    decoded = HashWithIndifferentAccess.new(decoded)
    decoded
  rescue JWT::ExpiredSignature
    puts ">>>>>>>>>>>>>>>>>>> Token has expired"
    nil
  rescue JWT::DecodeError
    puts ">>>>>>>>>>>>>>>>>>> Invalid token"
    nil
  end
end