class RedisStore
  # this is used for storing data that needs to be persisted across requests and mostly will be deleted in some another process
  REDIS = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))

  def self.set(key, value, expires_in: nil)
    if expires_in.present?
      REDIS.set(key, value, ex: expires_in)
    else
      REDIS.set(key, value)
    end
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

  def self.incrby(key, value)
    REDIS.incrby(key, value)
  end

  def self.decrby(key, value)
    REDIS.decrby(key, value)
  end
end