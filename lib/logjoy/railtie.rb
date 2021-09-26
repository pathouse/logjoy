require 'rails/railtie'

module Logjoy
  class Railtie < Rails::Railtie
    %i[action_controller action_view active_record action_mailer active_storage].each do |component|
      config.after_initialize do |app|
        ActiveSupport.on_load(component) do
          Logjoy.manage_log_subscribers(component)
        end
      end
    end
  end
end
