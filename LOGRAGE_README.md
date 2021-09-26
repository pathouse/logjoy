# Lograge vs. Logjoy

## How Lograge works:

- Monkeypatches `Rails::Rack::Logger`
- Monkeypatches `ActionCable` classes and adds custom
  `ActiveSupport::Notifications`
- Monkeypatches `ActionCable::Server` and replaces the logger w/ a no-op
- Detaches the default rails log subscribes for `ActionController` and
  `ActionView`
- Attaches its own custom log subscribers for `ActionController` and
  `ActionCable`
- Allows configuration to add custom data to logs
- provides a number of different formatters

## How Logjoy works

- no monkey patching anything
- provides an alternate set of log subscribers for each default Rails subscriber
  - action_controller
  - action_mailer
  - action_view
  - active_record
  - active_storage
- only provides JSON formatting or Rails default formatting

## TL;DR

The TL;DR here is that Logjoy is simpler and less opinionated in terms of
implementation with the trade off of being a little bit more involved to
configure. We stay away from monkeypatching Rails because that makes the code
harder to maintain (indeed, the monkeypatching is the reason I started working
on this gem to move away from Lograge)
