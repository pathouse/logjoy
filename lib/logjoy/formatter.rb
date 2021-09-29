# frozen_string_literal: true

module Logjoy
  class Formatter < ::Logger::Formatter
    REPLACE = 'REPLACEME'

    # msg is already formatted as JSON
    def call(severity, timestamp, progname, msg)
      fields = { level: severity, timestamp: timestamp }
      fields[:progname] = progname unless progname.nil?
      fields[:message] = REPLACE
      json = fields.to_json
      json.gsub(/"#{REPLACE}"/, msg)
    end
  end
end
