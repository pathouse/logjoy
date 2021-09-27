require 'rails/railtie'
require 'logjoy/configuration'
require 'logjoy/formatter'

module Logjoy
  class Railtie < Rails::Railtie
    config.logjoy = Logjoy::Configuration.new
    config.log_formatter = Logjoy::Formatter.new

    Logjoy::COMPONENTS.each do |component|
      config.after_initialize do |app|
        ActiveSupport.on_load(component) do
          Logjoy.manage_log_subscribers(app, component)
        end
      end
    end
  end
end
