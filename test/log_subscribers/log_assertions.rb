# frozen_string_literal: true

module Logjoy
  module LogAssertions
    def assert_log_has_keys(log, keys)
      keys.each do |key|
        assert_match(/#{key}/, log)
      end
    end
  end
end
