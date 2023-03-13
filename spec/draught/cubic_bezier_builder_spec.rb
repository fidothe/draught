require 'draught/cubic_bezier_builder'
require 'draught/world'

module Draught
  RSpec.describe CubicBezierBuilder do
    let(:world) { World.new }
    let(:end_point) { world.point.new(4,0) }
    let(:control_1) { world.point.new(1,2) }
    let(:control_2) { world.point.new(3,2) }
    subject { described_class.new(world) }

    specify "can generate a Point in the correct World" do
      cubic = subject.build(end_point: end_point, control_point_1: control_1, control_point_2: control_2)

      expect(cubic.end_point).to eq(end_point)
      expect(cubic.control_point_1).to eq(control_1)
      expect(cubic.control_point_2).to eq(control_2)
      expect(cubic.world).to be(world)
    end
  end
end
