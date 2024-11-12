module Trailblazer
  module Core
    module Utils
      def self.inspect(object)
        return Inspect.convert_hash_inspect(object) if object.is_a?(String)
        return object.inspect unless object.is_a?(Hash)

        old_string = object.inspect

        Inspect.convert_hash_inspect(old_string)
      end

      module Inspect
        def self.convert_hash_inspect(hash_inspect)
          new_string = hash_inspect.gsub(/([{ ])(\w+): /, '\1:\2=>')
          new_string.gsub(" => ", "=>")
        end
      end
    end
  end
end
