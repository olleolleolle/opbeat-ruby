module Opbeat
  module Integration
    class Resque
      def self.install
        begin
          require 'resque'
        rescue LoadError
        end

        require 'opbeat/integration/patches/resque' if defined?(Resque)
      end
    end
  end
end
