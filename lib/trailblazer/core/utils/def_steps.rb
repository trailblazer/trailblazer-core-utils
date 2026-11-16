module Trailblazer
  module Core::Utils
    # Helpers to quickly create steps and tasks.
    module DefSteps
      # Creates a module with one step method for each name.
      #
      # @example
      #   extend T.def_steps(:create, :save)
      def self.def_steps(*names)
        Module.new do
          module_function

          names.each do |name|
            define_method(name) do |ctx, seq:, **|
              ctx[:seq] = seq + [name]

              ctx.key?(name) ? ctx[name] : true
            end
          end
        end
      end

      # Creates a method instance with a task interface.
      #
      # @example
      #   task task: T.def_task(:create)
      def self.def_task(name, **options)
        def_tasks(name, **options).method(name)
      end

      # With {passthrough_signal: true}, a task returns the incoming signal instead of {success_signal}.
      def self.def_tasks(*names, success_signal: Activity::Right, passthrough_signal: false)
        Module.new do
          module_function

          names.each do |name|
            define_method(name) do |ctx, flow_options, incoming_signal, target_ctx:, **|
              seq = target_ctx[:seq] + [name]

              signal =
                if target_ctx.key?(name) then target_ctx[name]
                elsif passthrough_signal then incoming_signal
                else success_signal
                end

              return ctx.merge(target_ctx: target_ctx.merge(seq: seq)), flow_options, signal
            end
          end
        end
      end
    end
  end
end
