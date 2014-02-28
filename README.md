# Assembler

An [assembler swarm](http://en.wikipedia.org/wiki/Molecular_assembler) is a
bunch of nanomachines that can build [almost anything](http://en.wikipedia.org/wiki/Molecular_nanotechnology#Assemblers_versus_nanofactories).

Assembler is a library that gives you a DSL to describe a super-handy
initializer pattern. You specify the parameters your object should take and
Assembler give you an initializer that takes an options hash as well as yielding
a [builder object](http://c2.com/cgi/wiki?BuilderPattern) to a block. It takes
care of storing the parameters and gives you private accessors, too.


## Usage

TODO: Write usage instructions here


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
