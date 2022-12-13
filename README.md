# Trailblazer::Core::Utils

## Convert Activity tests to Operation tests

We currently don't use a `bin/` command.

```ruby
require "trailblazer/core"
Trailblazer::Core.convert_operation_test("test/docs/model_test.rb")
Trailblazer::Core.convert_operation_test("test/docs/each_test.rb")
```
