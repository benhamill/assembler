# Assembler
[![Build Status](https://travis-ci.org/benhamill/assembler.png)](https://travis-ci.org/benhamill/assembler)
[![Code Climate](https://codeclimate.com/github/benhamill/assembler.png)](https://codeclimate.com/github/benhamill/assembler)

An [assembler swarm](http://en.wikipedia.org/wiki/Molecular_assembler) is a
bunch of nanomachines that can build [almost anything](http://en.wikipedia.org/wiki/Molecular_nanotechnology#Assemblers_versus_nanofactories).

Assembler is a library that gives you a DSL to describe a super-handy
initializer pattern. You specify the parameters your object should take and
Assembler gives you an initializer that takes an options hash as well as
yielding a [builder object](http://c2.com/cgi/wiki?BuilderPattern) to a block.
It takes care of storing the parameters and gives you private accessors, too.

## Contents

* [Usage](#usage)
  * [assemble_from](#assemble_from)
  * [assemble_from_options](#assemble_from_options)
  * [Before and After Hooks](#before-and-after-hooks)
* [Contributing](#contributing)


## Usage

### `assemble_from`

The `assemble_from` method is the core of Assembler. It's also aliased as
`assemble_with`. The basic use case is to pass in required parameters followed
by optional parameters (and their defaults). Take this simple example:

```ruby
class IMAPConnection
  extend Assembler

  assemble_from :hostname, use_ssl: true, port: nil

  # Additional business logic here...
end
```

This enables you to instantiate your object with either an options hash or via a
block. For example:

```ruby
# These two are equivalent:
IMAPConnection.new(hostname: 'imap.example.com')
IMAPConnection.new do |aw|
  aw.hostname = 'imap.example.com'
end

# These two are equivalent:
IMAPConnection.new(hostname: 'imap.example.com', use_ssl: false)
IMAPConnection.new do |aw|
  aw.hostname = 'imap.example.com'
  aw.use_ssl = false
end

# Or you can do a combination, if you need to:
IMAPConnection.new(hostname: 'imap.example.com') do |aw|
  aw.use_ssl = false
end
```

Note that when you set `use_ssl` to `false`, the code respects that, rather than
over-writing anything falsey with the default. If you don't want that, override
it like with `port`, below.

You get private `attr_reader`s for the parameters you specify, but you can
always override them, if you like. You might have this lower down in your
`IMAPConnection` class:

```ruby
class IMAPConnection
  attr_reader :hostname # makes `hostname` public

  def ssl?
    !!use_ssl
  end

  def port
    @port ||= ssl? ? 993 : 143
  end
end
```

These various syntaxes enable some trickery when you're dealing with a world of
uncertainty. Let's look at a more complicated example.

Say you want a class that lets us describe an Elastic Load Balancer for Amazon
Web Services. There's a lot of complexity in what each of these arguments might
be, but the key thing for this example is this: If you have `subnets`, you
shouldn't have `availability_zones` and if you have `availability_zones`, you
shouldn't have `subnets`. And, importantly, you shouldn't send in extraneous
keys; you need to be able to differentiate callers sending `nil` explicitly from
not sending in anything when you make whatever API calls you're going to make to
Amazon.

```ruby
class AmazonELB
  extend Assembler
  assemble_from(
    :name,
    load_balancer_name: nil,
    health_check: nil,
    listeners: nil,
    security_groups: nil,
    instances: nil,
    subnets: nil,
    availability_zones: nil,
  )

  # Additional, complex business logic...
end
```

Now, since there's a lot of complexity in what each of these arguments might be,
say you've developed some best-practices about what each of them should be. And
you want to make it easy to pop off slight variations on what you consider to be
a "standard" ELB.

``` ruby
module ELBFactory
  def self.make_me_an_elb(subnet_ids=nil, availability_zones=nil, name_prefix='', instance_ids=[], security_groups=[])
    AmazonELB.new do |elb|
      elb.name = name(name_prefix)
      elb.load_balancer_name = name(name_prefix)
      elb.security_groups = security_groups
      elb.instance_ids = instance_ids

      elb.health_check = HealthCheck.new(
        target: 'HTTP:8000/',
        healthy_threshold: '3',
        unhealthy_threshold: '5',
        interval: '30',
        timeout: '5'
      )
      elb.listeners = [Listener.new(...), Listener.new(...)]

      if subnet_ids
        elb.subnets = subnet_ids
      else
        elb.availability_zones = availability_zones
      end
    end
  end

  def self.name(name_prefix)
    "#{sanitize_for_name(name_prefix)}LoadBalancer"
  end

  def self.sanitize_for_name(string)
    # ...
  end
end
```

Note the `if`/`else` block near the end of the initialization block. If the
initialization method only took hashes, you would either have to wrap object
creation in an `if`/`else` and repeat all the constructor arguments that were
shared between the two cases, or else pre-construct your argument hash, which
would look similar to the above, but require you to assign an intermediate
variable for no semantic benefit.


### `assemble_from_options`

If you need to do something more complicated than what's provided by
`assemble_from`, you can specify per-argument options using
`assemble_from_options`. Like `assemble_from`, it's also aliased as
`assemble_with_options`.

Default values can be specified using the `:default` option, and work the same
as using hash-syntax with `assemble_from`.

If you would like to do some type of value coercion you can specify either a
symbol or a callable using the `:coerce` option. Symbols will be passed as
messages to the input object, and anything that responds to `#call` will be
called with the input object as an argument.

If you need to accept aliased key names you can use the `:aliases` option to
specify a list of keys. Aliases only apply to input processing; instance
variables aren't set and accessors aren't be provided.

```ruby
class IMAPConnection
  extend Assembler

  # Here we want to assign an IP address so we only do DNS lookup once.
  assemble_from_options :hostname, coerce: ->(h) { Resolv.getaddress(h) }

  # Defaults must be specified explicitly; arguments with no default are required.
  assemble_from_options :use_ssl, default: false

  # We'll accept values named 'port' or 'host_port' (but we'll only assign '@port').
  # Symbols can also be passed for coercions.
  assemble_from_options :port, default: nil, coerce: :to_i, aliases: [:host_port]
end

instance = IMAPConnection.new(hostname: 'localhost') do |b|
  puts b.hostname   # => '127.0.0.0' - i.e. the accessor returns the coerced value.
  puts b.use_ssl    # => false - i.e. the accessor returns the default value if none is specified.
  b.port = '100'    # Will be coerced to the integer 100.
end

instance.host_port  # => MethodMissing error - accessors aren't defined for aliases.
```

### Before and After Hooks

In some cases, you might need to take care of some extra things during object
initialization. One simple case would be if you're inheriting from another class
and need to call `super` to make sure it initializes correctly. Enter
`before_assembly` and `after_assembly`.

They both take a block and that block gets evaluated in the scope of your
instance before or after the rest of Assembler's initializer runs. This means
instance variables and private methods are available to you and that `self` is
the object being created. Nothing is `yield`ed to the blocks.

If you don't need to pass arguments or always pass the same arguments, you could
do something like this:

```ruby
class Professor < Employee
  extend Assembler

  before_assembly do
    super('teaching')
  end
end
```

If, however, you need to react to or interact with options that are passed in,
you can do something like this:

```ruby
class Professor < Employee
  extend Assembler

  attr_reader :title

  assemble_with :department_name, :degree_subject
  after_assembly do
    @title = "PhD of #{degree_subject}, #{department_name}"
  end
end
```


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
