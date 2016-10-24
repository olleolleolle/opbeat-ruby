module Opbeat
  module Integration
    class Sidekiq
      def self.install
        begin
          require 'sidekiq'
        rescue LoadError
        end

        require 'opbeat/integration/patches/sidekiq' if defined?(Sidekiq)
      end
    end
  end
end
