module Trailblazer
  module Core::Utils
    module AssertRun
# TODO: Use .Builder() and never build a node here.
      def assert_run(circuit = nil, id = nil, node: nil, terminus: nil, seq: nil,
          flow_options: Circuit::Node::Runner.new(), signal: nil, target_ctx: {seq: []}, expected_target_variables: {}, **lib_ctx)
        # If circuit isn't a Node instance already, wrap it in a "canonical node".
        canonical_node = node ? node : Trailblazer::Circuit::Node[circuit, Trailblazer::Circuit::Processor] # TODO: remove :node and figure it out automatically.

        lib_ctx = lib_ctx.merge(target_ctx: target_ctx)

        # TODO: use the public Invoke.call API! will save us some lines of code above.
        # lib_ctx, flow_options, signal = Activity::Invoke.invoke_runner(lib_ctx, flow_options, signal, **circuit_options)
        lib_ctx, flow_options, signal = flow_options.(lib_ctx, flow_options, signal, canonical_node, id)

        if terminus.is_a?(Symbol)
          terminus = circuit.to_h[:outputs].fetch(terminus).signal
        end

        assert_equal signal, terminus, "Expected terminus #{terminus.inspect} does not match actual #{signal.inspect}"

        target_ctx = lib_ctx[:target_ctx]

        assert_equal target_ctx[:seq], seq, ":seq does not match" # FIXME: test all ctx variables.

        # if expected_target_ctx
        #   assert_equal target_ctx, expected_target_ctx
        # end
        expected_target_variables.each do |k, v| # TODO: test me. what about exception, is it readable?
          assert_equal target_ctx[k], v
        end

        return lib_ctx, flow_options, signal
      end
    end
  end
end

# FIXME: test **lib_ctx
