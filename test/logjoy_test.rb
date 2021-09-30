# frozen_string_literal: true

require 'test_helper'

class App
  attr_reader :config

  def initialize
    @config = ActiveSupport::OrderedOptions.new
    @config.logjoy = ActiveSupport::OrderedOptions.new
    @config.logjoy.enabled = true
  end

  def enabled_logjoy
    @config.logjoy.enabled = true
  end

  def disable_logjoy
    @config.logjoy.enabled = false
  end
end

class LogjoyTest < Minitest::Test
  def setup
    @notifier = ActiveSupport::Notifications::Fanout.new
    @old_notifier = ActiveSupport::Notifications.notifier
    ActiveSupport::Notifications.notifier = @notifier
  end

  def teardown
    ActiveSupport::Notifications.notifier = @old_notifier
  end

  def test_that_it_has_a_version_number
    refute_nil ::Logjoy::VERSION
  end

  def test_detach_default_subscriber
    ActionController::LogSubscriber.attach_to :action_controller
    wait
    assert_equal 1, ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller').size

    Logjoy.detach_default_subscriber(app, :action_controller)
    wait
    assert_equal 0, ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller').size
  end

  def test_attach_subscriber
    assert_equal 0, ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller').size
    Logjoy.attach_subscriber(app, :action_controller)
    wait
    assert_equal 1, ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller').size
    Logjoy::LogSubscribers::ActionController.detach_from :action_controller
  end

  def test_custom_fields
    app.config.logjoy.customizer = ->(event) { { additional: event.payload[:etc] } }
    Logjoy.set_customizer(app)

    event = ActiveSupport::Notifications::Event.new(
      'event',
      Time.now,
      Time.now + 1,
      'tranactionid',
      { data: 'information', etc: 'stuff' }
    )

    assert_equal({ additional: 'stuff' }, Logjoy.custom_fields(event))
  end

  def app
    @app ||= App.new
  end

  def wait
    ActiveSupport::Notifications.notifier.wait
  end
end
