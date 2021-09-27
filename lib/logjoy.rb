# frozen_string_literal: true

require_relative 'logjoy/version'

module Logjoy
  class Error < StandardError; end
  module_function

  COMPONENTS = %i[action_controller action_view active_record action_mailer active_storage].freeze

  def manage_log_subscribers(app, component)
    config = component_config(app, component)
    return unless config.enabled?
    # TODO:
    # if logjoy is configured to use its own log subscribers for this component
    # then detach the rails defaults and attach our own
    # otherwise do nothing
  end

  def component_config(app, component)
    app.config.logjoy.public_send(component)
  end
end

require 'logjoy/railtie'
