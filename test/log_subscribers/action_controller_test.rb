# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
# rubocop:disable Lint/RescueException
# rubocop:disable Lint/RaiseException
# rubocop:disable Lint/InheritException

require 'action_controller'
require 'active_support/log_subscriber/test_helper'
require 'json'
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
    @old_logger = ActionController::Base.logger
    @routes = ActionDispatch::Routing::RouteSet.new
    ActiveSupport::Deprecation.silence do
      @routes.draw { get ':controller(/:action)' }
    end

    Logjoy::LogSubscribers::ActionController.attach_to :action_controller
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
    ActionController::Base.logger = @old_logger
  end

  def set_logger(logger)
    ActionController::Base.logger = logger
  end

  def assert_log_has_keys(log, keys)
    parsed_log = JSON.parse(log)
    keys.each do |key|
      assert parsed_log.key?(key)
    end
  end

  def assert_log_has_status(log, status)
    parsed_log = JSON.parse(log)
    assert_equal status, parsed_log['status']
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

  def test_process_action_with_filtered_path
    Logjoy.filters = ['/another/log_subscribers/show']
    get :show
    wait
    assert_equal 0, logs.size
  end

  def test_process_action_with_exception_includes_http_status_code
    begin
      get :with_exception
      wait
    rescue Exception
    end
    assert_equal 1, logs.size
    assert_log_has_status(logs.first, 500)
  end

  def test_process_action_with_rescued_exception_includes_http_status_code
    get :with_rescued_exception
    wait

    assert_equal 1, logs.size
    assert_log_has_status(logs.first, 406)
  end

  def test_process_action_with_with_action_not_found_logs_404
    begin
      get :with_action_not_found
      wait
    rescue AbstractController::ActionNotFound
    end

    assert_equal 1, logs.size
    assert_log_has_status(logs.first, 404)
  end

  def test_process_action_with_customizer
    Logjoy.customizer = ->(_event) { { additional: 'stuff' } }

    get :show
    wait

    assert_log_has_keys(logs.first, %w[additional])
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
