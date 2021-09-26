# frozen_string_literal: true

require_relative "logjoy/version"

module Logjoy
  class Error < StandardError; end

  def manage_log_subscribers(component)
    # TODO:
    # if logjoy is configured to use its own log subscribers for this component
    # then detach the rails defaults and attach our own
    # otherwise do nothing
  end
end
