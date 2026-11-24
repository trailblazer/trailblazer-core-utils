require "forwardable"
require "trailblazer/core/utils/strip"
require "trailblazer/core/utils/def_steps"
require "trailblazer/core/utils/assert_run"
require "trailblazer/core/utils/assert_equal"
require "trailblazer/core/utils/fixture"

module Trailblazer
  module Core
    # def self.convert_operation_test(*args, **kws)
    #   Utils::ConvertOperationTest.(*args, **kws)
    # end

    class << self
      extend Forwardable
      def_delegator Utils::DefSteps, :def_steps
      def_delegator Utils::DefSteps, :def_tasks
      def_delegator Utils::DefSteps, :def_task
      def_delegator Utils::Fixture,  :pipe
    end
  end
end

