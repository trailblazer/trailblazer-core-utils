require "test_helper"

class HashInspectTest < Minitest::Spec
  class Memo < Struct.new(:id); end

  it "converts Ruby 3.4+ {Hash#inspect} to old style, so our tests don't have to be changed" do
    hsh = {
      symbol: {symbol: 1, "string" => 2},
      "string" => 1,
      Memo.new(1) => true,
      method(:inspect) => 9,
      seq: [:a, :b],
    }

    #<Method: Trailb

    # puts Trailblazer::Core::Utils.inspect(hsh)
    assert_equal Trailblazer::Core::Utils.inspect(hsh), %({:symbol=>{:symbol=>1, "string"=>2}, "string"=>1, #<struct HashInspectTest::Memo id=1>=>true, #<Method: HashInspectTest(Kernel)#inspect()>=>9, :seq=>[:a, :b]})
  end

  it "can convert only the hash part of a longer string" do
    assert_equal Trailblazer::Core::Utils.inspect("A string {with: true, and: 1} a hash"), %(A string {:with=>true, :and=>1} a hash)
  end

  it "converts hash in inspected oobjects, too" do
    hash_inspect = %(#<Trailblazer::Context::Container wrapped_options={model: Module} mutable_options={ctx_in_model: "#<Trailblazer::Context::Container wrapped_options={model: Module} mutable_options={}>"}>)

    assert_equal Trailblazer::Core::Utils::Inspect.convert_hash_inspect(hash_inspect),
      %(#<Trailblazer::Context::Container wrapped_options={:model=>Module} mutable_options={:ctx_in_model=>"#<Trailblazer::Context::Container wrapped_options={:model=>Module} mutable_options={}>"}>)
  end

#   it "can convert multi-line strings" do
#     multi_line = %(Actual contract errors: \e[33m{:title=>[\"must be filled\"], :content=>[\"must be filled\", \"size cannot be less than 8\"]}\e[0m.
# --- expected
# +++ actual
# @@ -1 +1 @@
# -{:title=>[\"is XXX\"]}
# +{:title=>[\"must be filled\"], :content=>[\"must be filled\", \"size cannot be less than 8\"]}
# )

#     assert_equal Trailblazer::Core::Utils.inspect("A string {with: true, and: 1} a hash"), %(A string {:with=>true, :and=>1} a hash)
#   end

  it "doesn't convert non-hashes in multi-line strings" do
    multi_line = %({Trailblazer::Test::Testing::Memo::Operation::Create} didn't fail, it passed.
Expected: false
  Actual: true)

    assert_equal Trailblazer::Core::Utils.inspect(multi_line), %({Trailblazer::Test::Testing::Memo::Operation::Create} didn't fail, it passed.
Expected: false
  Actual: true)
  end

  it "uses native {#inspect} for other classes" do
    assert_equal Trailblazer::Core::Utils.inspect(Struct.new(:id).new(1)), %(#<struct id=1>)
  end
end
