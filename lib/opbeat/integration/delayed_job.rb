module Opbeat
  module Integration
    class DelayedJob
      def self.install
        begin
          require 'active_support'
          require 'delayed_job'
        rescue LoadError
        end

        require 'opbeat/integration/patches/delayed_job' if defined?(Delayed)
      end
    end
  end
end

