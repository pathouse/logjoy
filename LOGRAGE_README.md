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
- Detaches the default Rails log subscribers for
  - action controller
  - action view
  - action mailer
  - active storage
- Attaches a new log subscriber for
  - action_controller
- only provides JSON formatting
- allows configuration to add custom data to logs

## TL;DR

Logjoy is very similar to Lograge with a few key differences

- no monkeypatching
- no change to action cable logs
- only JSON formatting

We stay away from monkeypatching Rails because that makes the code
harder to maintain (indeed, the monkeypatching is the reason I started working
on this gem to move away from Lograge)
