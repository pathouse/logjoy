# frozen_string_literal: true

require 'active_support/log_subscriber'
require 'action_controller/base'
require 'action_controller/log_subscriber'

module Logjoy
  module LogSubscribers
    class ActionController < ActiveSupport::LogSubscriber
      def process_action(event)
        return if ignore_event?(event)

        info do
          payload = event.payload

          log = payload.slice(:controller, :action, :format, :method, :status)
          log[:path] = strip_query(payload[:path])
          log[:view_runtime] = rounded_ms(payload[:view_runtime])
          log[:db_runtime] = rounded_ms(payload[:db_runtime])
          log[:duration] = rounded_ms(event.duration)
          log[:params] = cleanup_params(payload[:params])
          log[:request_id] = payload[:request].request_id
          log[:event] = event.name
          log[:allocations] = event.allocations

          if log[:status].nil? && (exception_class_name = payload[:exception]&.first)
            log[:exception] = exception_class_name
            log[:status] = ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
          end

          log.merge(Logjoy.custom_fields(event)).to_json
        end
      end

      def logger
        ::ActionController::Base.logger
      end

      private

      def strip_query(path_with_query)
        uri = URI.parse(path_with_query)
        uri.path
      end

      def ignore_event?(event)
        Logjoy.filters.include?(event.payload[:path])
      end

      def rounded_ms(value)
        return 'N/A' if value.nil?

        value.round(3)
      end

      def cleanup_params(params)
        params.except(*::ActionController::LogSubscriber::INTERNAL_PARAMS)
      end
    end
  end
end
