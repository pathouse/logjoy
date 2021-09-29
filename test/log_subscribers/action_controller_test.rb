# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
# rubocop:disable Lint/RescueException
# rubocop:disable Lint/RaiseException
# rubocop:disable Lint/InheritException

require 'action_controller'
require 'active_support/log_subscriber/test_helper'
require 'logjoy/log_subscribers/action_controller'

module Another
  class LogSubscribersController < ActionController::Base
    class SpecialException < Exception
    end

    rescue_from SpecialException do
      head 406
    end

    def show
      head :ok
    end

    def with_exception
      raise Exception
    end

    def with_rescued_exception
      raise SpecialException
    end

    def with_action_not_found
      raise AbstractController::ActionNotFound
    end
  end
end

class ACLogSubscriberTest < ActionController::TestCase
  tests Another::LogSubscribersController
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super
    @old_logger = Logjoy.logger
    @routes = ActionDispatch::Routing::RouteSet.new
    ActiveSupport::Deprecation.silence do
      @routes.draw { get ':controller(/:action)' }
    end

    Logjoy::LogSubscribers::ActionController.attach_to :action_controller
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
    Logjoy.logger = @old_logger
  end

  def set_logger(logger)
    Logjoy.logger = logger
  end

  def assert_log_has_keys(log, keys)
    keys.each do |key|
      assert_match(/#{key}/, log)
    end
  end

  def test_process_action
    get :show
    wait
    assert_equal 1, logs.size
    keys = %w[
      controller
      action
      format
      method
      path
      status
      view_runtime
      db_runtime
      duration
      params
      request_id
      event
      allocations
      status
    ]
    assert_log_has_keys(logs.first, keys)
  end

  def test_process_action_with_exception_includes_http_status_code
    begin
      get :with_exception
      wait
    rescue Exception
    end
    assert_equal 1, logs.size
    assert_match(/500/, logs.first)
  end

  def test_process_action_with_rescued_exception_includes_http_status_code
    get :with_rescued_exception
    wait

    assert_equal 1, logs.size
    assert_match(/406/, logs.first)
  end

  def test_process_action_with_with_action_not_found_logs_404
    begin
      get :with_action_not_found
      wait
    rescue AbstractController::ActionNotFound
    end

    assert_equal 1, logs.size
    assert_match(/404/, logs.first)
  end

  def test_process_action_with_customizer
    Logjoy.customizer = ->(_event) { { additional: 'stuff' } }

    get :show
    wait

    assert_log_has_keys(logs.first, %w[custom additional])

    Logjoy.customizer = nil
  end

  def logs
    @logs ||= @logger.logged(:info)
  end
end

# rubocop:enable Lint/SuppressedException
# rubocop:enable Lint/RescueException
# rubocop:enable Lint/RaiseException
# rubocop:enable Lint/InheritException
