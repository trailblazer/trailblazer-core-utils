module Trailblazer
  module Core
    module Utils
      module Render
        module_function

        def railway(activity)
          activity.to_h[:circuit].nodes.keys.reject { |id| id =~ /End/ }.inspect
        end
      end
    end
  end
end
