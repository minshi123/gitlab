# frozen_string_literal: true

module Spam
  module SpamConstants
    REQUIRE_RECAPTCHA = "recaptcha"
    DISALLOW = "disallow"
    ALLOW = "allow"
    BLOCK_USER = "block"

    VALID_VERDICTS = [BLOCK_USER, DISALLOW, REQUIRE_RECAPTCHA, ALLOW]
  end
end
