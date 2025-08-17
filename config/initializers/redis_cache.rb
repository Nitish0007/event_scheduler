class RedisCache
  # this is used to store data temporarily and will be deleted after 1 day if not manually given the expires_in parameter
  REDIS = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))

  def self.set(key, value, expires_in: 1.day)
    REDIS.set(key, value, ex: expires_in)
  end

  def self.exists?(key)
    REDIS.exists(key) == 1
  end

  def self.get(key)
    REDIS.get(key)
  end

  def self.delete(key)
    REDIS.del(key)
  end
end