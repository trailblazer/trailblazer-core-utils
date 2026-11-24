require "test_helper"

class FixtureTest < Minitest::Spec
  include Trailblazer::Core::Utils::AssertRun

  it "test fixture()" do
    _, pipe = Trailblazer::Core::Utils::Fixture.pipe("top",
      :a,
      Trailblazer::Core::Utils::Fixture.pipe("bc",
        :b,
        :c,
        Trailblazer::Core::Utils::Fixture.pipe("d",
          :d),
        :e),
      :f,
      Trailblazer::Core::Utils::Fixture.pipe("g-",
        :g,
        Trailblazer::Core::Utils::Fixture.pipe("hi",
          :h,
          :i),),
      :j
    )

    assert_run pipe, seq: [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j], terminus: Object
  end

  it "we can use {:helper} to build steps differently" do

  end

  it "Helper.add_to_seq" do

  end

  it "Helper.add_to_seq_in" do

  end
end
