require "test_helper"

class DefStepsTest < Minitest::Spec
  it "{#def_tasks}" do
    my_right  = Class.new
    tasks     = Trailblazer::Core.def_tasks(:a, :b, success_signal: my_right)

    lib_ctx, flow_options, signal, *remaining = tasks.method(:a).({}, {application_ctx: {seq: []}}, nil)

    assert_equal lib_ctx, {}
    assert_equal flow_options, {application_ctx: {seq: [:a]}}
    assert_equal signal, my_right
    assert_equal remaining, []
  end

  it "{#def_tasks} in an Activity" do
    skip

    tasks = Trailblazer::Core.def_tasks(:a, success_signal: my_right)
    steps = Trailblazer::Core.def_steps(:b, success_signal: my_right)

    activity = Class.new(Trailblazer::Activity::Railway) do
      step task: tasks.method(:a)
      include steps
      step :b
    end

    ctx, _, signal = activity.({seq: []}, {})
    assert_equal

    assert_equal Trailblazer::Core::Utils.inspect(ctx), %({:seq=>[:a, :b]})
  end
end
