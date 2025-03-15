require "test_helper"

class StripTest < Minitest::Spec
  it "removes IDs like 0x1abc from string" do
    assert_equal Trailblazer::Core::Utils.strip(%(#{Class.new}...#{Object.new})), %(#<Class:0x>...#<Object:0x>)
  end
end
