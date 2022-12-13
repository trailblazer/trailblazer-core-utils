require "forwardable"
require "trailblazer/core/utils/convert_operation_test"
require "trailblazer/core/utils/symbol_inspect_for"

module Trailblazer
  module Core
    # def self.convert_operation_test(*args, **kws)
    #   Utils::ConvertOperationTest.(*args, **kws)
    # end

    class << self
      extend Forwardable
      def_delegator Utils::ConvertOperationTest, :call, :convert_operation_test
      def_delegator Utils, :symbol_inspect_for
    end
  end
end

