module Trailblazer
  module Core::Utils
    module AssertEqual
      def assert_equal(asserted, expected, *args)
        super(expected, asserted, *args)
      end
    end
  end
end
