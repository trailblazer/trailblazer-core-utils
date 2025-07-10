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
            define_method(name) do |ctx, **|
              ctx[:seq] << name
              ctx.key?(name) ? ctx[name] : true
            end
          end
        end
      end

      # Creates a method instance with a task interface.
      #
      # @example
      #   task task: T.def_task(:create)
      def self.def_task(name)
        def_tasks(name).method(name)
      end

      def self.def_tasks(*names)
        Module.new do
          module_function

          names.each do |name|
            define_method(name) do |(ctx, flow_options), **|
              ctx[:seq] << name
              signal = ctx.key?(name) ? ctx[name] : Activity::Right

              return signal, [ctx, flow_options]
            end
          end
        end
      end
    end
  end
end
