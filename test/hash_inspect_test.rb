require "test_helper"

class HashInspectTest < Minitest::Spec
  class Memo < Struct.new(:id); end

  it "converts Ruby 3.4+ {Hash#inspect} to old style, so our tests don't have to be changed" do
    hsh = {
      symbol: {symbol: 1, "string" => 2},
      "string" => 1,
      Memo.new(1) => true,
      method(:inspect) => 9,
    }

    #<Method: Trailb

    puts Trailblazer::Core::Utils.inspect(hsh)
    assert_equal Trailblazer::Core::Utils.inspect(hsh), %({:symbol=>{:symbol=>1, "string"=>2}, "string"=>1, #<struct HashInspectTest::Memo id=1>=>true, #<Method: HashInspectTest(Kernel)#inspect()>=>9})
  end

  it "uses native {#inspect} for other classes" do
    assert_equal Trailblazer::Core::Utils.inspect(Struct.new(:id).new(1)), %(#<struct id=1>)
  end
end
