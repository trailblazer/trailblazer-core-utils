require "test_helper"
require "trailblazer/circuit"

class AssertRunTest < Minitest::Spec
  include Testable::AssertTestCaseFails

  T = Trailblazer::Core

  class MyExecContext
    def self.a(lib_ctx, flow_options, _, target_ctx:, **)
      lib_ctx = lib_ctx.merge(target_ctx: target_ctx.merge(seq: target_ctx[:seq] + [:a]))

      return lib_ctx, flow_options, nil
    end
  end


  class MySpec < Minitest::Spec
    include Testable

    let(:my_exec_context) do
      MyExecContext
    end

    include Trailblazer::Core::Utils::AssertRun
  end

  include Trailblazer::Core::Utils::AssertRun

  let(:my_exec_context) { MyExecContext }

  let(:my_pipe) do
    Trailblazer::Circuit::Builder.Pipeline(
      [:a, my_exec_context.method(:a)],
    )
  end

  it "{:terminus} defaults to nil" do
    lib_ctx, flow_options, signal = assert_run my_pipe, seq: [:a]

    assert_nil signal
  end

  it "accepts {:terminus} which is the expected returned last signal" do
    my_callable = ->(lib_ctx, flow_options, signal, **) { return lib_ctx, flow_options, "Left" }

    my_pipe = Trailblazer::Circuit::Builder.Pipeline(
      [:a, my_callable],
    )

    lib_ctx, flow_options, signal = assert_run my_pipe, seq: [],
      terminus: "Left"

    assert_equal signal, "Left"
  end

  it "accepts {terminus: :semantic} and automatically extracts the Terminus instance for you" do
    my_activity = Class.new(Trailblazer::Activity::Railway) do
      step :a
      include T.def_steps(:a)
    end

    lib_ctx, flow_options, signal = assert_run my_activity, seq: [:a],
      terminus: :success

    assert_equal signal.inspect, "#<struct Trailblazer::Activity::Terminus::Success semantic=:success>"
  end

  it "raises with non-matching {:terminus}" do
    _test = Class.new(MySpec) do
      it do
        my_pipe = Trailblazer::Circuit::Builder.Pipeline(
          [:a, my_exec_context.method(:a)],
        )

        lib_ctx, flow_options = assert_run my_pipe, seq: [],
          terminus: Object
      end
    end

    assert_test_case_fails _test, error_message: "Expected terminus Object does not match actual nil.
Expected: Object
  Actual: nil"
  end

  it "raises with non-matching {:seq}" do
    _test = Class.new(MySpec) do
      it do
        my_pipe = Trailblazer::Circuit::Builder.Pipeline(
          [:a, my_exec_context.method(:a)],
        )

        lib_ctx, flow_options = assert_run my_pipe, seq: [:a, :b]
      end
    end

    assert_test_case_fails _test, error_message: ":seq does not match.
Expected: [:a, :b]
  Actual: [:a]"
  end

  it "accepts {:seq} which is the expected {target_ctx[:seq]} variable after running the node" do
    lib_ctx, flow_options, signal = assert_run my_pipe,
      seq: [:a]
  end

  it "returns {lib_ctx, flow_options, signal}" do
    lib_ctx, flow_options, signal = assert_run my_pipe, seq: [:a]

    assert_equal lib_ctx, {target_ctx: {seq: [:a]}}
    assert_equal flow_options, {}
    assert_nil signal
  end

  it "accepts {node: true}" do
    my_node = Trailblazer::Circuit::Node::MergeToCircuitOptions[:a, Trailblazer::Circuit::Task::Adapter::LibInterface::InstanceMethod, merge_to_circuit_options: {exec_context: MyExecContext}]

    lib_ctx, flow_options, signal = assert_run my_node, seq: [:a],
      node: true
  end

  it "accepts {:target_ctx}" do
    lib_ctx, flow_options = assert_run my_pipe, seq: [:x, :a],
      target_ctx: {seq: [:x]}
  end

  it "accepts {:flow_options}" do
    _, flow_options = assert_run my_pipe, seq: [:a],
      flow_options: {trace: true}

    assert_equal flow_options, {trace: true}
  end

  it "accepts {:circuit_options} to add variables to lib_ctx" do
    my_pipe = Trailblazer::Circuit::Builder.Pipeline(
      [:a, :a, Trailblazer::Circuit::Task::Adapter::LibInterface::InstanceMethod],
    )

    lib_ctx, flow_options = assert_run my_pipe, seq: [:a],
      circuit_options: {exec_context: my_exec_context, runner: Trailblazer::Circuit::Node::Runner}
  end
end
