# frozen_string_literal: true
require 'json'

module Logjoy
  class Formatter < ::Logger::Formatter
    def call(severity, timestamp, progname, msg)
      msg = JSON.parse(msg)

      { level: severity, timestamp: timestamp, progname: progname, message: msg }.to_json
    end
  end
end
