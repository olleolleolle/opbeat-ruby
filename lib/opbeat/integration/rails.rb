module Opbeat
  module Integration
    class Rails
      def self.install
        begin
          require 'rails'
        rescue LoadError
        end

        require 'opbeat/integration/patches/rails' if defined?(Rails)
      end
    end
  end
end

