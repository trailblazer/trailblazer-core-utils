module Trailblazer
  module Core::Utils
     module Assertions
      # `:seq` is always passed into ctx.
      # @param :seq String What the {:seq} variable in the result ctx looks like. (expected seq)
      # @param :expected_ctx_variables Variables that are added during the call by the asserted activity.
      def assert_call(activity, terminus: :success, seq: "[]", expected_ctx_variables: {}, **ctx_variables)
        # Call without taskWrap!
        signal, (ctx, _) = activity.([{seq: [], **ctx_variables}, _flow_options = {}]) # simply call the activity with the input you want to assert.

        assert_call_for(signal, ctx, terminus: terminus, seq: seq, **expected_ctx_variables, **ctx_variables)
      end

      # Use {TaskWrap.invoke} to call the activity.
      def assert_invoke(activity, terminus: :success, seq: "[]", circuit_options: {}, flow_options: {}, expected_ctx_variables: {}, **ctx_variables)
        signal, (ctx, returned_flow_options) = Activity::TaskWrap.invoke(
          activity,
          [
            {seq: [], **ctx_variables},
            flow_options,
          ],
          **circuit_options
        )

        assert_call_for(signal, ctx, terminus: terminus, seq: seq, **ctx_variables, **expected_ctx_variables) # DISCUSS: ordering of variables?

        return signal, [ctx, returned_flow_options]
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

        cct = cct.gsub("#<Trailblazer::Activity::TaskBuilder::Task user_proc=", "<*")
        assert_equal circuit.to_s, cct
      end

      def Cct(activity)
        Activity::Introspect::Render.(activity, inspect_task: Assertions.method(:render_task))
      end
    end

    # Use this in {#Cct}.
    def self.render_task(proc)
      Activity::Introspect.render_task(proc)
    end
  end
end
