# frozen_string_literal: true

require 'rails/railtie'

require_relative 'configuration'

module Logjoy
  class Railtie < Rails::Railtie
    config.logjoy = Logjoy::Configuration.new

    config.after_initialize do |app|
      Logjoy.manage_global_settings(app)
    end

    Logjoy::COMPONENTS.each do |component|
      config.after_initialize do |app|
        Logjoy.manage_log_subscribers(app, component)
      end
    end
  end
end
