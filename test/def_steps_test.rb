require "test_helper"

class DefStepsTest < Minitest::Spec
  it "{#def_tasks}" do
    tasks = Trailblazer::Core.def_tasks(:a)
    steps = Trailblazer::Core.def_steps(:b)

    activity = Class.new(Trailblazer::Activity::Railway) do
      step task: tasks.method(:a)
      include steps
      step :b
    end

    signal, (ctx, _) = activity.([{seq: []}])

    assert_equal ctx.inspect, %({:seq=>[:a, :b]})
  end
end
