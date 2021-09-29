# frozen_string_literal: true

require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'action_mailer/log_subscriber'
require 'active_storage/log_subscriber'

require_relative 'logjoy/version'
require_relative 'logjoy/log_subscribers/action_controller'

module Logjoy
  class Error < StandardError; end
  module_function

  mattr_accessor :customizer

  def custom_fields(event)
    return {} if customizer.nil?

    customizer.call(event)
  end

  def set_customizer(app)
    return unless enabled?(app)

    self.customizer = app.config.logjoy.customizer
  end

  REPLACE_SUBSCRIBERS = %i[action_controller].freeze
  DETACH_SUBSCRIBERS = %i[action_view action_mailer active_storage].freeze

  def detach_default_subscriber(app, component)
    return unless enabled?(app)

    default_subscriber(component).detach_from(component)
  end

  def attach_subscriber(app, component)
    return unless enabled?(app)

    logjoy_subscriber(component).attach_to(component)
  end

  def default_subscriber(component)
    "#{component.to_s.camelize}::LogSubscriber".constantize
  end

  def logjoy_subscriber(component)
    "Logjoy::LogSubscribers::#{component.to_s.camelize}".constantize
  end

  def enabled?(app)
    app.config.logjoy.enabled
  end
end

require 'logjoy/railtie'
