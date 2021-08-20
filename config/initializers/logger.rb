module ActiveSupport
  module TaggedLogging
    module Formatter # :nodoc:
      def scrub_long_source(input)
        input.gsub(/\["encoded_blueprint", ".*, \["/, '["encoded_blueprint", "REDACTED"], ["')
      end

      alias orig_call call

      def call(severity, timestamp, progname, msg)
        orig_call(severity, timestamp, progname, scrub_long_source(msg))
      end
    end
  end
end
