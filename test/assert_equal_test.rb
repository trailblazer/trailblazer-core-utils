require "test_helper"

class AssertEqualTest < Minitest::Spec
  include Testable::AssertTestCaseFails

  it "flips arguments" do
    class MySpec < Minitest::Spec
      include Testable
      # include Trailblazer::Core::Utils::AssertEqual

      it do
        assert_equal "actual", "expected", "error! not a match"
      end
    end

    assert_test_case_fails MySpec, error_message: %(error! not a match.
Expected: "expected"
  Actual: "actual")
  end
end
