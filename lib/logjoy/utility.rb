# frozen_string_literal: true

module Logjoy
  module Utility
    def rounded_ms(value)
      return 'N/A' if value.nil?

      value.round(3)
    end
  end
end
