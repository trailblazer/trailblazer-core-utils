require "test_helper"
require "trailblazer/circuit"


class AssertRunTest < Minitest::Spec

  def assert_test_case_fails(test, number: 1, error_message:)
    test_case = test.new(:"test_000#{number}_anonymous")
    failures, assertions, _ = test_case.()

    assert_equal failures.size, 1
    # pp failures[0].message
    assert_equal failures[0].to_s, error_message
  end

  # TODO: this is also used in {trb-test}.
  class MySpec < Minitest::Spec
    def call
      run
      return @failures, @assertions, @result
    end

    let(:my_exec_context) do
      Class.new do # FIXME: use #def_tasks
        def a(lib_ctx, flow_options, signal, **)
          flow_options[:application_ctx][:seq] << :a

          return lib_ctx, flow_options, signal
        end
      end.new
    end

    include Trailblazer::Core::Utils::AssertRun
  end

  include Trailblazer::Core::Utils::AssertRun

  let(:my_exec_context) do
    Class.new do
      def a(lib_ctx, flow_options, signal, **)
        flow_options[:application_ctx][:seq] << :a

        return lib_ctx, flow_options, signal
      end
    end.new
  end

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
    my_callable = ->(lib_ctx, flow_options, signa) { return lib_ctx, flow_options, :Left }

    my_pipe = Trailblazer::Circuit::Builder.Pipeline(
      [:a, my_callable],
    )

    lib_ctx, flow_options, signal = assert_run my_pipe, seq: [],
      terminus: :Left

    assert_equal signal, :Left
  end

  it "raises with non-matching {:terminus}" do
    _test = Class.new(MySpec) do
      it do
        my_pipe = Trailblazer::Circuit::Builder.Pipeline(
          [:a, my_exec_context.method(:a)],
        )

        lib_ctx, flow_options = assert_run my_pipe, seq: [],
          terminus: :Left
      end
    end

    assert_test_case_fails _test, error_message: "Expected: :Left
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

    assert_test_case_fails _test, error_message: "Expected: [:a, :b]\n  Actual: [:a]"
  end

  it "accepts {:seq} which is the expected {application_ctx[:seq]} variable after running the node" do
    lib_ctx, flow_options, signal = assert_run my_pipe,
      seq: [:a]
  end

  it "returns {lib_ctx, flow_options, signal}" do
    lib_ctx, flow_options, signal = assert_run my_pipe, seq: [:a]

    assert_equal lib_ctx, {}
    assert_equal flow_options, {application_ctx: {seq: [:a]}}
    assert_nil signal
  end

  it "accepts {node: true}" do
    my_node = Trailblazer::Circuit::Node::Scoped[:d, my_pipe, Trailblazer::Circuit::Processor]

    lib_ctx, flow_options, signal = assert_run my_node, seq: [:a],
      node: true
  end

  it "accepts {:lib_ctx}" do
    my_pipe = Trailblazer::Circuit::Builder.Pipeline(
      [:a, :a, Trailblazer::Circuit::Task::Adapter::LibInterface::InstanceMethod],
    )

    assert_run my_pipe, seq: [:a],
      lib_ctx: {exec_context: my_exec_context}
  end

  it "accepts {:flow_options}" do
    assert_run my_pipe, seq: [:x, :a],
      flow_options: {application_ctx: {seq: [:x]}}
  end

  it "accepts {**application_ctx} to add variables to the input {application_ctx}" do
    lib_ctx, flow_options = assert_run my_pipe, seq: [:a],
      mode: :override

    assert_equal flow_options, {application_ctx: {seq: [:a], mode: :override}}
  end
end
