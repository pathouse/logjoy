# frozen_string_literal: true

module Logjoy
  class Formatter < ActiveSupport::Logger::SimpleFormatter
    def call(severity, timestamp, progname, msg)
      { level: severity, timestamp: timestamp, progname: progname, message: msg }.to_json
    end
  end
end
