module Gitlab
  module Cache
    # Used to cache a bunch of related key/value pairs such that you can
    # efficiently expire/delete the entire group of key/value pairs. This is
    # useful when you can't use the normal Rails cache because it would be too
    # expensive to iterate over all keys and delete them when it is necessary
    # to expire the entire cache.
    #
    # Under the hood this is implemented using a Redis Hash and deleting is
    # just a `DEL` of the entire Hash.
    class GroupedCache
      class << self

        TTL_UNSET = -1
        DEFAULT_EXPIRES_IN = 1.day

        # Just like Rails::Cache.fetch but you provide the group name as well
        # as the key for the specific item within the group.
        def fetch(group_name, key, expires_in: DEFAULT_EXPIRES_IN, &blk)
          Gitlab::Redis::Cache.with do |redis|
            cached_result = redis.hget(group_name, key)

            return cached_result unless cached_result.nil?

            value = yield
            redis.hset(group_name, key, value)

            if redis.ttl(group_name) == TTL_UNSET
              redis.expire(group_name, expires_in)
            end

            yield
          end
        end

        # Deletes the entire cache for this group. All keys in the group will
        # be removed.
        def delete(group_name)
          Gitlab::Redis::Cache.with { |redis| redis.del(group_name) }
        end
      end
    end
  end
end
