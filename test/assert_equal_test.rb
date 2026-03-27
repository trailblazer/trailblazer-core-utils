require "test_helper"

class AssertEqualTest < Minitest::Spec
  include Testable::AssertTestCaseFails

  it "flips arguments" do
    class MySpec < Minitest::Spec
      include Testable

      it do
        assert_equal "actual", "expected"
      end
    end

    assert_test_case_fails MySpec, error_message: %(Expected: "expected"
  Actual: "actual")
  end
end
