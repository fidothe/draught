require 'draught/circle_builder'
require 'draught/world'

module Draught
  RSpec.describe CircleBuilder do
    let(:world) { World.new }
    subject { CircleBuilder.new(world) }

    describe "creating a Circle" do
      let(:circle) { subject.new(radius: 100) }

      it "reports its radius" do
        expect(circle.radius).to eq(100)
      end
    end
  end
end
