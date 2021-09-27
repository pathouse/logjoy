# frozen_string_literal: true
require 'pry'

require_relative 'logjoy/version'
require_relative 'logjoy/formatter'
require_relative 'logjoy/log_subscribers/action_controller'

module Logjoy
  class Error < StandardError; end
  module_function

  def manage_global_settings(app)
    app.config.log_formatter = Formatter
  end

  COMPONENTS = %i[action_controller action_view active_record action_mailer active_storage].freeze

  def manage_log_subscribers(app, component)
    config = component_config(app, component)
    return unless config.enabled

    default_subscriber(component).detach_from(component)
    logjoy_subscriber(component).attach_to(component)
  end

  def component_config(app, component)
    app.config.logjoy.public_send(component)
  end

  def default_subscriber(component)
    "#{component.to_s.camelize}::LogSubscriber".constantize
  end

  def logjoy_subscriber(component)
    "Logjoy::LogSubscribers::#{component.to_s.camelize}".constantize
  end
end

require 'logjoy/railtie'
