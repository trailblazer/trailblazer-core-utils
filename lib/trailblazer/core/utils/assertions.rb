module Trailblazer
  module Core::Utils
    module Assertions
      # `:seq` is always passed into ctx.
      # @param :seq String What the {:seq} variable in the result ctx looks like. (expected seq)
      # @param :expected_ctx_variables Variables that are added during the call by the asserted activity.
      def assert_call(activity, terminus: :success, seq: "[]", expected_ctx_variables: {}, **ctx_variables)
        # Call without taskWrap!
        ctx, _, signal = activity.({seq: [], **ctx_variables}, _flow_options = {}, {}) # simply call the activity with the input you want to assert.

        assert_call_for(signal, ctx, terminus: terminus, seq: seq, **expected_ctx_variables, **ctx_variables)
      end

      # Use {TaskWrap.invoke} to call the activity.
      def assert_invoke(activity, terminus: :success, seq: "[]", circuit_options: {}, flow_options: {}, expected_ctx_variables: {}, **ctx_variables)
        ctx, returned_flow_options, signal = Activity::TaskWrap.invoke(
          activity,
          {seq: [], **ctx_variables},
          flow_options,
          circuit_options
        )

        assert_call_for(signal, ctx, terminus: terminus, seq: seq, **ctx_variables, **expected_ctx_variables) # DISCUSS: ordering of variables?

        return ctx, returned_flow_options, signal
      end

      def assert_call_for(signal, ctx, terminus: :success, seq: "[]", **ctx_variables)
        assert_equal signal.to_h[:semantic], terminus, "assert_call expected #{terminus} terminus, not #{signal}. Use assert_call(activity, terminus: #{signal.to_h[:semantic].inspect})"

        assert_equal ctx.inspect, {seq: "%%%"}.merge(ctx_variables).inspect.sub('"%%%"', seq)

        return ctx
      end

      # Tests {:circuit} and {:outputs} fields so far.
      def assert_process_for(process, *args)
        semantics, circuit = args[0..-2], args[-1]

        assert_equal semantics.sort, process.to_h[:outputs].collect { |output| output[:semantic] }.sort

        assert_circuit(process, circuit)

        process
      end

      alias_method :assert_process, :assert_process_for

      def assert_circuit(schema, circuit)
        cct = Cct(schema)

        binary_step_pattern = %(#<Trailblazer::Activity::Circuit::Step::Binary:0x @step=#<Trailblazer::Activity::Circuit::Step::Option:0x @step=#<Trailblazer::Activity::Option::InstanceMethod:0x @filter=:)
        binary_step_pattern = %(#<Trailblazer::Activity::Circuit::Step::Binary:0x @step=#<Trailblazer::Activity::Circuit::Step::Option:0x @step=#<Trailblazer::Activity::Option::InstanceMethod:0x @filter=:)

        # TODO: this makes a binary_step inspect readable.
        cct = cct.gsub(binary_step_pattern, "<*")
        cct = cct.gsub(">>>", ">")

        assert_equal cct, circuit.to_s
      end

      def Cct(activity)
        Activity::Introspect::Render.(activity, inspect_task: method(:render_task))
      end

      module_function
      # Use this in {#Cct}.
      def render_task(proc)
        Activity::Introspect.render_task(proc)
      end
    end

  end
end
