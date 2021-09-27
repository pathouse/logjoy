require 'active_support/ordered_options'

module Logjoy
  class Configuration
    attr_accessor *Logjoy::COMPONENTS

    def initialize
      Logjoy::COMPONENTS.each do |component|
        public_send("#{component}=", ActiveSupport::OrderedOptions.new)
      end
    end
  end
end
