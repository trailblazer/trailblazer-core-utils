module Trailblazer
  module Core
    module Utils
      # Convert an Activity test into an operation test.
      # Store at {test/docs/autogenerated/operation_model_test.rb}
      #
      # {#~ctx_to_result} allows to

      module ConvertOperationTest
        def self.call(filepath)
          within_marker = false
          within_ignore = false
          within_ctx_to_result = false

          op_test =
          File.foreach(filepath).collect do |line|
            if line.match(/#:[\w]+/) # FIXME: we don't use this!
              within_marker = true
            end
            if line.match(/#:.+ end/)
              within_marker = false
            end

            if line.match(/#~ignore/) # FIXME: we don't use this!
              within_ignore = true
            end
            if line.match(/#~ignore end/)
              within_ignore = false
            end

            if line.match(/#~ctx_to_result/)
              within_ctx_to_result = true
            end
            if line.match(/#~ctx_to_result end/)
              within_ctx_to_result = false
            end

            if within_ignore
              # puts "@@@@@ #{line.inspect}"
              line = ""
            else
              line = line.sub("< Trailblazer::Activity::Railway", "< Trailblazer::Operation")
              line = line.gsub("::Activity", "::Operation")

              # if within_marker
                line = line.sub("signal, (ctx, _) =", "result =")
                if within_ctx_to_result
                  line = line.sub("ctx[", "result[")
                end

                if match = line.match(/(Trailblazer::Operation\.\(([\w:]+), ?)/)
                  activity = match[2]
                  line = line.sub(match[0], "#{activity}.(")
                end

                if match = line.match(/(\s+)puts signal.+(:\w+)>/)
                  semantic = match[2]
                  line = "#{match[1]}result.success? # => #{semantic == ":success" ?  true : false}\n"
                end
              # end

              line = line.sub("assert_equal ctx", "assert_equal result")
              line = line.sub("assert_equal signal", "assert_equal result.event")
            end

            line
          end

          op_test.insert(1, "module Autogenerated")
          op_test << "end"

          File.write "test/docs/autogenerated/operation_" + File.basename(filepath), op_test.join("")
        end

      end # ConvertOperationTest
    end
  end
end
