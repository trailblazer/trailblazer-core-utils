module Trailblazer
  module Core::Utils
    module AssertRun
      def assert_run(circuit, node: false, terminus: nil, seq:, flow_options: {}, application_ctx: {}, **lib_ctx)
        runner = Trailblazer::Circuit::Node::Runner

        # If circuit isn't a Node instance already, wrap it in a "canonical node".
        canonical_node = node ? circuit : Trailblazer::Circuit::Node[:my_canonical, circuit, Trailblazer::Circuit::Processor]

        circuit_options = {}
        circuit_options = circuit_options.merge(runner: runner)
        circuit_options = circuit_options.merge(context_implementation: Trailblazer::Circuit::Context) # FIXME: remove

        flow_options = {application_ctx: {seq: [], **application_ctx}, **flow_options}

        lib_ctx, flow_options, signal = runner.(canonical_node, lib_ctx, flow_options, nil, **circuit_options)

        assert_equal signal, terminus
        assert_equal flow_options[:application_ctx][:seq], seq # FIXME: test all ctx variables.

        return lib_ctx, flow_options, signal
      end
    end
  end
end
