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

    ctx, _, signal = activity.({seq: []}, {})

    assert_equal Trailblazer::Core::Utils.inspect(ctx), %({:seq=>[:a, :b]})
  end
end
