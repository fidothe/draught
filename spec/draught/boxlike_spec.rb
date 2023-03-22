require 'draught/world'
require 'draught/boxlike_examples'
require 'draught/boxlike'
require 'draught/spec_box'

module Draught
  RSpec.describe Boxlike do
    let(:world) { World.new }
    subject { SpecBox.new(world, {
      lower_left: world.point.new(10,10),
      width: 20, height: 10
    }) }

    it_should_behave_like "a basic rectangular box-like thing"
  end
end
