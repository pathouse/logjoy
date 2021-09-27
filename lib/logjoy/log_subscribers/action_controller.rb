# frozen_string_literal: true

require 'pry'
require 'active_support/log_subscriber'

module Logjoy
  module LogSubscribers
    # https://guides.rubyonrails.org/active_support_instrumentation.html#action-controller

    class ActionController < ActiveSupport::LogSubscriber
      def start_processing(event)
        binding.pry
      end

      def process_action(event)
        binding.pry
      end

      def halted_callback(event)
        binding.pry
      end

      def send_file(event)
        binding.pry
      end

      def redirect_to(event)
        binding.pry
      end

      def send_data(event)
        binding.pry
      end

      def unpermitted_parameters(event)
        binding.pry
      end

      def logger
        ::ActionController::Base.logger
      end
    end
  end
end
