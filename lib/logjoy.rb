# frozen_string_literal: true

require_relative 'logjoy/version'
require_relative 'logjoy/formatter'

module Logjoy
  class Error < StandardError; end
  module_function

  def manage_global_settings(app)
    app.config.log_formatter ||= Formatter
  end

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
