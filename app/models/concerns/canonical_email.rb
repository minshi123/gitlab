# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  INCLUDED_DOMAINS_PATTERN = [/gmail.com/].freeze

  def canonicalize_email
    return unless email

    portions = email.split('@')
    username = portions.shift
    rest = portions.join

    regex = Regexp.union(INCLUDED_DOMAINS_PATTERN)
    return unless regex.match?(rest)

    no_dots = username.tr('.', '')
    before_plus = no_dots.split('+')[0]
    "#{before_plus}@#{rest}"
  end
end
