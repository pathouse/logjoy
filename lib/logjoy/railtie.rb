# frozen_string_literal: true

require 'active_support/ordered_options'
require 'rails/railtie'

module Logjoy
  class Railtie < Rails::Railtie
    config.logjoy = ActiveSupport::OrderedOptions.new

    config.after_initialize do |app|
      Logjoy.set_customizer(app)
    end

    config.after_initialize do |app|
      Logjoy.set_path_filters(app)
    end

    Logjoy::REPLACE_SUBSCRIBERS.each do |component|
      config.after_initialize do |app|
        Logjoy.detach_default_subscriber(app, component)
        Logjoy.attach_subscriber(app, component)
      end
    end

    Logjoy::DETACH_SUBSCRIBERS.each do |component|
      config.after_initialize do |app|
        Logjoy.detach_default_subscriber(app, component)
      end
    end
  end
end
