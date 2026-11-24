module Trailblazer
  module Core
    module Utils
      module Fixture
        module_function

        # TODO: test :helper, def_task, add_to_seq...
        def pipe(id, *steps, helper: Trailblazer::Core, success_signal: Object)
          step_args = steps.collect do |step|
            step.is_a?(Array) ?
              [step.first, step.last, Circuit::Processor] :
              [step, helper.def_task(step, success_signal: success_signal)]
          end

          my_pipe = Circuit::Builder.Pipeline(*step_args)

          return id, my_pipe
        end
      end
    end
  end
end
