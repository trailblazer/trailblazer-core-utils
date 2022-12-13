# Trailblazer::Core::Utils

## Convert Activity tests to Operation tests

In order to show users both `Activity` and `Operation` tests, we have a converter.
This implies converted tests are written in a specific style.

We currently don't use a `bin/` command.

```ruby
require "trailblazer/core"
Trailblazer::Core.convert_operation_test("test/docs/model_test.rb")
Trailblazer::Core.convert_operation_test("test/docs/each_test.rb")
```
