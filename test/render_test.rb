require "test_helper"

class RenderTest < Minitest::Spec
  it "#railway renders all node IDs excluding the FastTrack termini" do
    my_activity = Class.new(Trailblazer::Activity::Railway) do
      step :a
      step :b
      # include T.def_steps(:a)
    end

    assert_equal Trailblazer::Core.railway(my_activity), %([:a, :b])
  end
end
