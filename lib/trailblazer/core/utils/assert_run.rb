module Trailblazer
  module Core::Utils
    module AssertRun
      # DISCUSS: use Invoke.call() here?
      def assert_run(circuit, node: false, terminus: nil, seq:, flow_options: {}, signal: nil, circuit_options: {runner: Trailblazer::Circuit::Node::Runner}, target_ctx: {seq: []}, **lib_ctx)
        # If circuit isn't a Node instance already, wrap it in a "canonical node".
        canonical_node = node ? circuit : Trailblazer::Circuit::Node[circuit, Trailblazer::Circuit::Processor] # TODO: remove :node and figure it out automatically.

        # circuit_options = {runner: runner}.merge(circuit_options)
        runner = circuit_options.fetch(:runner)
        circuit_options = circuit_options.merge(node: canonical_node)
        circuit_options = circuit_options.merge(context_implementation: Trailblazer::Circuit::Context) # FIXME: remove

        lib_ctx = lib_ctx.merge(target_ctx: target_ctx)

        # TODO: use the public Invoke.call API! will save us some lines of code above.
        # lib_ctx, flow_options, signal = Activity::Invoke.invoke_runner(lib_ctx, flow_options, signal, **circuit_options)
        lib_ctx, flow_options, signal = runner.(lib_ctx, flow_options, signal, **circuit_options)

        if terminus.is_a?(Symbol)
          terminus = circuit.to_h[:outputs].fetch(terminus).signal
        end

        assert_equal signal, terminus, "Expected terminus #{terminus.inspect} does not match actual #{signal.inspect}"

        target_ctx = lib_ctx[:target_ctx]

        assert_equal target_ctx[:seq], seq, ":seq does not match" # FIXME: test all ctx variables.

        return lib_ctx, flow_options, signal
      end
    end
  end
end

# FIXME: test **lib_ctx
