# Assembler
[![Build Status](https://travis-ci.org/benhamill/assembler.png)](https://travis-ci.org/benhamill/assembler)
[![Code Climate](https://codeclimate.com/github/benhamill/assembler.png)](https://codeclimate.com/github/benhamill/assembler)

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
class IMAPConnection
  extend Assembler

  assemble_from :hostname, use_ssl: true, port: nil

  # Additional business logic here...
end
```

Then you can instantiate your object with either an options hash or via a block.
For example:

```ruby
# These two are equivalent:
IMAPConnection.new(hostname: 'imap.example.com')
IMAPConnection.new do |aw|
  aw.required_param = 'imap.example.com'
end

# These two are equivalent:
IMAPConnection.new(hostname: 'imap.example.com', use_ssl: false)
IMAPConnection.new do |aw|
  aw.hostname = 'imap.example.com'
  aw.use_ssl = false
end
```

Note that when we set `use_ssl` to `false`, the code respects that, rather than
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

Say we've got a class that lets us describe an Elastic Load Balancer for Amazon
Web Services. There's a lot of complexity in what each of these arguments might
be, but the key thing for our example is this: If you have `subnets`, you
shouldn't have `availability_zones` and if you have `availability_zones`, you
shouldn't have `subnets`. And, importantly, you shouldn't send in extraneous
keys.

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
say we've developed some best-practices about what each of them should be. And
we want to make it easy to pop off slight variations on what we consider to be a
"standard" ELB.

``` ruby
module ELBFactory
  def self.make_me_an_elb(subnet_ids=nil, availability_zones=nil, name_prefix='', instance_ids=[], security_groups=[])
    AmazonELB.new do |elb|
      elb.name = name
      elb.load_balancer_name = name
      elb.security_groups = security_groups
      elb.instance_ids = instance_ids

      elb.health_check =  HealthCheck.new (
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

Note that the `if`/`else` block near the end of the initialization block. If the
initialization method only took hashes, you could either have to wrap object
creation in an `if`/`else` and repeat all the constructor arguments that were
shared between the two cases, or else pre-construct your argument hash, which
would look similar to the above, but require you to assign an intermediate
variable for no semantic benefit.


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
