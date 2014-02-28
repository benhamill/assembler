# Assembler

An [assembler swarm](http://en.wikipedia.org/wiki/Molecular_assembler) is a
bunch of nanomachines that can build [almost anything](http://en.wikipedia.org/wiki/Molecular_nanotechnology#Assemblers_versus_nanofactories).

Assembler is a library that gives you a DSL to describe a super-handy
initializer pattern. You specify the parameters your object should take and
Assembler give you an initializer that takes an options hash as well as yielding
a [builder object](http://c2.com/cgi/wiki?BuilderPattern) to a block. It takes
care of storing the parameters and gives you private accessors, too.


## Usage

You use it like this:

```ruby
class AwesomeThing
  extend Assembler

  assembler_initializer :required_param, optional_param: 'default value'

  # Additional business logic here...
end
```

Then you can instantiate your object with either an options hash or via a block.
For example:

```ruby
# These two are equivalent:
AwesomeThing.new(required_param: 'specialness')
AwesomeThing.new do |aw|
  aw.required_param = 'specialness'
end

# These two are equivalent:
AwesomeThing.new(required_param: 'specialness', optional_param: 'override')
AwesomeThing.new do |aw|
  aw.required_param = 'specialness'
  aw.optional_param = 'override'
end
```

This enables some trickery when you're dealing with a world of uncertainty:

```ruby
class Foo
  extend Assembler
  assembler_initializer :name, :awesome, favorite_color: 'green'

  def awesome?
    !!awesome
  end
end

def delegating_method(name, awesome=true, favorite_color=nil)
  Foo.new do |foo|
    foo.name = name
    foo.awesome = awesome

    foo.favorite_color = favorite_color if favorite_color
  end
end
```

The delegating method, here, is empowered to reverse the default for `awesome`,
but then respect the default for `favorite_color` if the calling code doesn't
pass anything in (assuming `nil` is unacceptable). It also respects if `awesome`
has a falsey value passed in.

Especially when you have objects with a lot of potential arguments being passed
in and don't want to pass keys that you don't have any information about (did
my caller pass in this `nil`, or is it my own default?), you can use conditional
logic in the block, rather than conditionally build of a hash just to pass to a
constructor method.


## Contributing

Help is gladly welcomed. If you have a feature you'd like to add, it's much more
likely to get in (or get in faster) the closer you stick to these steps:

1. Open an Issue to talk about it. We can discuss whether it's the right
  direction or maybe help track down a bug, etc.
1. Fork the project, and make a branch to work on your feature/fix. Master is
  where you'll want to start from.
1. Turn the Issue into a Pull Request. There are several ways to do this, but
  [hub](https://github.com/defunkt/hub) is probably the easiest.
1. Make sure your Pull Request includes tests.
1. Bonus points if your Pull Request updates `CHANGES.md` to include a summary
   of your changes and your name like the other entries. If the last entry is
   the last release, add a new `## Unreleased` heading at the top.

If you don't know how to fix something, even just a Pull Request that includes a
failing test can be helpful. If in doubt, make an Issue to discuss.
