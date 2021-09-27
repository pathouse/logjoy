# frozen_string_literal: true

require 'pry'
require 'active_support/log_subscriber'

module Logjoy
  module LogSubscribers
    # https://guides.rubyonrails.org/active_support_instrumentation.html#action-controller

    class ActionController < ActiveSupport::LogSubscriber
      def start_processing(event)
        info do
          payload = event.payload

          log = payload.slice(:controller, :action, :format, :method, :path)
          log[:params] = cleanup_params(payload[:params])
          log[:request_id] = payload[:request].request_id
          log[:event] = event.name
          log
        end
      end

      def process_action(event)
        info do
          payload = event.payload

          log = payload.slice(:controller, :action, :format, :method, :path, :status)
          log[:view_runtime] = payload[:view_runtime].round
          log[:db_runtime] = payload[:view_runtime].round
          log[:duration] = event.duration.round
          log[:params] = cleanup_params(payload[:params])
          log[:request_id] = payload[:request].request_id
          log[:event] = event.name
          log[:allocations] = event.allocations

          if log[:status].nil? && (exception_class_name = payload[:exception]&.first)
            log[:exception] = exception_class_name
            log[:status] = ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
          end

          log
        end
      end

      def halted_callback(event)
        debug do
          {
            filter: event.payload[:filter].inspect,
            event: event.name
          }
        end
      end

      def send_file(event)
        info do
          {
            path: event.payload[:path],
            duration: event.duration.round,
            event: event.name
          }
        end
      end

      def redirect_to(event)
        info do
          payload = event.payload

          log = payload.slice(:status, :location)
          log[:request_id] = payload[:request].request_id
          log[:event] = event.name
          log
        end
      end

      def send_data(event)
        info do
          {
            filename: event.payload[:filename],
            duration: event.duration.round,
            event: event.name
          }
        end
      end

      def unpermitted_parameters(event)
        debug do
          {
            keys: event[:payload].keys,
            event: event.name
          }
        end
      end

      %w[
        write_fragment
        read_fragment
        exist_fragment?
        expire_fragment
        expire_page
        write_page
      ].each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{method}(event)
          return unless ActionController::Base.enable_fragment_cache_logging

          info do
            {
              key: ActiveSupport::Cache.expand_cache_key(event.payload[:key] || event.payload[:path]),
              duration: event.duration.round,
              event: event.name
            }
          end
        end
        METHOD
      end

      def logger
        ::ActionController::Base.logger
      end

      private

      def cleanup_params(params)
        params.except(*::ActionController::LogSubscriber::INTERNAL_PARAMS)
      end
    end
  end
end
