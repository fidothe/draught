# Draught - a Geometry library for creating vector graphics

> draught, v.
>
> 2. To make a plan or sketch of; esp. to draw a preliminary plan of (something to be constructed); to design. (Sometimes draft.)
>
> [Oxford English Dictionary](http://www.oed.com/view/Entry/57521?result=2&rskey=9oHsDI)

Draught is a library for creating vector graphics as SVGs and PDFs. It's grown out of generating shapes that can be laser cut, and that's still its focus.

TODO: Explain the fundamental concepts

## Installation

To use it as a library add this line to your application's Gemfile:

```ruby
gem 'draught'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install draught

## Usage

Example docs are bad and I will fix them.

Also having to require everything individually.

Create a simple straight line and add it to a sheet, then generate an SVG with it:

```ruby
require 'draught/world'
require 'draught/segment/line'
require 'draught/bounding_box'
require 'draught/sheet'
require 'draught/renderer/svg'

world = Draught::World.new
line_segment = world.line_segment.horizontal(100).translate(world.vector.new(100,100))
box = Draught::BoundingBox.new(world, [line_segment])
sheet = Draught::Sheet.new(world, width: 300, height: 200, containers: [box])

renderer = Draught::Renderer::SVG.render_to_file('./example.svg', sheet)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fidothe/draught. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
