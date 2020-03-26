# frozen_string_literal: true

return if Gitlab::Database.read_only?

Shard.populate!
