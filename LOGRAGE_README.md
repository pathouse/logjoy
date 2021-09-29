# Lograge vs. Logjoy

Please note: this comparison is accurate as of the writing of this document -
[lograge v0.11.2](https://github.com/roidrage/lograge/releases/tag/v0.11.2)

So if you are reading this at a later date this may not be entirely accurate.

Both this gem and lograge are relatively small codebases so I encourage you to
take a look and make your own comparison.

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

Monkeypatching Rails is avoided because that makes the code harder to maintain.

As a result, Logjoy is not as aggressive about cleaning up certain default Rails logs such as
the request started logs:

> `Started GET "/" for ::1 at 2021-09-2900:25:00 -0400`
