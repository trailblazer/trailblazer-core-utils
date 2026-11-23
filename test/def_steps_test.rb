require "test_helper"

class DefStepsTest < Minitest::Spec
  it "{#def_task}" do
    task = Trailblazer::Core.def_task(:a, success_signal: Object)

    lib_ctx, flow_options, signal, *remaining = task.(options = {target_ctx: {seq: []}}, {}, nil, **options)

    assert_equal lib_ctx, {target_ctx: {seq: [:a]}}
    assert_equal flow_options, {}
    assert_equal signal, Object
    assert_equal remaining, []
  end

  it "{#def_tasks}" do
    my_right  = Class.new
    tasks     = Trailblazer::Core.def_tasks(:a, :b, success_signal: my_right)

    lib_ctx, flow_options, signal, *remaining = tasks.method(:a).(options = {target_ctx: {seq: []}}, {}, nil, **options)

    assert_equal lib_ctx, {target_ctx: {seq: [:a]}}
    assert_equal flow_options, {}
    assert_equal signal, my_right
    assert_equal remaining, []

    lib_ctx, flow_options, signal, *remaining = tasks.method(:b).(lib_ctx, flow_options, nil, **lib_ctx)
    assert_equal lib_ctx, {target_ctx: {seq: [:a, :b]}}
    assert_equal flow_options, {}
  end

  it "{#def_tasks} with {passthrough_signal: true} returns the incoming signal" do
    tasks = Trailblazer::Core.def_tasks(:a, success_signal: nil, passthrough_signal: true)

    _, _, signal = tasks.method(:a).(options = {target_ctx: {seq: []}}, {}, Object, **options)
    assert_equal signal, Object

    _, _, signal = tasks.method(:a).(options = {target_ctx: {seq: [], a: Class}}, {}, Object, **options)
    assert_equal signal, Class # an explicit {target_ctx[name]} still wins.
  end

  it "{#def_steps}" do
    my_right  = Class.new
    tasks     = Trailblazer::Core.def_steps(:a, :b)

    application_ctx = {seq: []}

    return_value = tasks.method(:a).(application_ctx, **application_ctx)

    assert_equal return_value, true
    assert_equal application_ctx, {seq: [:a]}

    return_value = tasks.method(:b).(application_ctx, **application_ctx)

    assert_equal return_value, true
    assert_equal application_ctx, {seq: [:a, :b]}
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

  it "#def_steps doesn't mutate the {seq} array" do
    my_exec_context = Trailblazer::Core.def_steps(:a)
    seq    = []
    my_ctx = {seq: seq}

    my_exec_context.method(:a).(my_ctx, **my_ctx)

    assert_equal my_ctx, {seq: [:a]}
    assert_equal seq, [] # seq hasn't changed
  end

  it "#def_tasks doesn't mutate the {seq} array" do
    my_exec_context = Trailblazer::Core.def_tasks(:a)
    seq    = []
    my_ctx = {seq: seq}
    lib_ctx = {target_ctx: my_ctx}

    new_lib_ctx, _ = my_exec_context.method(:a).(lib_ctx, {}, nil, **lib_ctx)

    assert_equal new_lib_ctx, {target_ctx: {seq: [:a]}}
    assert_equal seq, [] # nothing has changed
    assert_equal my_ctx, {seq: []}
    assert_equal lib_ctx, {target_ctx: {seq: []}}
  end
end
