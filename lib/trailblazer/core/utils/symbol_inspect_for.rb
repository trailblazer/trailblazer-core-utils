module Trailblazer
  module Core
    module Utils
      # Used to test {missing keyword} exceptions in all Ruby versions.
      def self.symbol_inspect_for(name)
        if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7.0") || RUBY_ENGINE == 'jruby'
          "#{name}"
        else
          ":#{name}"
        end
      end
    end
  end
end
