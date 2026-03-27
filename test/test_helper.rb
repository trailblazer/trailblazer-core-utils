$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "trailblazer/core"

require "minitest/autorun"

Minitest::Spec.class_eval do
  include Trailblazer::Core::Utils::AssertEqual
end

module Testable
# TODO: this is also used in {trb-test}.
  def call
    run
    return @failures, @assertions, @result
  end

  module AssertTestCaseFails
    def assert_test_case_fails(test, number: 1, error_message:)
      test_case = test.new(:"test_000#{number}_anonymous")
      failures, assertions, _ = test_case.()

      assert_equal failures.size, 1
      # pp failures[0].message
      assert_equal failures[0].to_s, error_message
    end
  end
end
