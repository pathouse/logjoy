# frozen_string_literal: true

require 'active_support/log_subscriber'

module Logjoy
  module LogSubscribers
    # https://guides.rubyonrails.org/active_support_instrumentation.html#action-controller

    class ActionController < ActiveSupport::LogSubscriber
      def start_processing(event)
        # TODO
        # merge event.payload with configured options
        # log as json at the level normally logged in rails
      end

      def process_action(event)
        # TODO
      end

      def halted_callback(event)
        # TODO
      end

      def send_file(event)
        # TODO
      end

      def redirect_to(event)
        # TODO
      end

      def send_data(event)
        # TODO
      end

      def unpermitted_parameters(event)
        # TODO
      end

      def logger
        ActionController::Base.logger
      end
    end
  end
end
