module Trailblazer
  module Core
    module Utils
      def self.inspect(object)
        return object.inspect unless object.is_a?(Hash)

        old_string = object.inspect
        # old_string = %({{symbol: 1, "string" => 2},"string" => 1})

        new_string = old_string.gsub(/(\w+): /, ':\1=>')
        new_string = new_string.gsub(" => ", "=>")

        return new_string
        "asdfafasdff"

        # if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7.0") || RUBY_ENGINE == 'jruby'
        #   "#{name}"
        # else
        #   ":#{name}"
        # end
      end
    end
  end
end
