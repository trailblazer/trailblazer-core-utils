module Trailblazer
  module Core
    module Utils
      # Remove object IDs for anonymous objects.
      def self.strip(string)
        string.gsub(/0x\w+/, "0x")
      end
    end
  end
end
