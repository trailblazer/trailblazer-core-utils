$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "trailblazer/core"

require "minitest/autorun"

Minitest::Spec.class_eval do
  def assert_equal(asserted, expected, *args)
    super(expected, asserted, *args)
  end
end
