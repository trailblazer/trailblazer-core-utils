module Trailblazer
  module Core
    def self.convert_operation_test(*args, **kws)
      Utils::ConvertOperationTest.(*args, **kws)
    end
  end
end

require "trailblazer/core/utils/convert_operation_test"
