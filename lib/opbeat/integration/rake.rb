module Opbeat
  module Integration
    class Rake
      def self.install
        require 'opbeat/integration/patches/rake'
      end
    end
  end
end
