# Changes

## Unreleased

* Add ability to access (optionally) coerced values on the builder object, for
  example Foo.new(some: 'value') {|b| puts b.some}. (Ryan Michael)
* Add `assemble_from_options` DSL method for defining coercions and aliases (Ryan Michael)
* Add `before_assembly` and `after_assembly` hooks. (Ben Hamill)

## 1.1.0

* Make Ruby 1.9-compatible. (Ryan Michael)
* Rename `assembler_initializer` to `assemble_from`. (Ben Hamill)
* Better examples in the README. (Ben Hamill)

## 1.0.0

* Initial Release. (Ben Hamill)
