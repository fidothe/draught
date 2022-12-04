require 'draught/vector'
require 'draught/world'
require 'draught/point_builder'
require 'draught/transformations/shared_examples'

module Draught
  RSpec.describe Vector do
    let(:world) { World.new }
    let(:point_builder) { world.point }
    let(:radians) { Math.atan(4/3.0) }
    let(:degrees) { radians * (180.0 / Math::PI) }

    context "comparison" do
      subject { Vector.new(1, 2, world) }

      it "compares equal to another vector with the same x, y" do
        expect(subject).to eq(Vector.new(1, 2, world))
      end

      it "does not compare equal to a Point with the same x, y" do
        expect(subject).not_to eq(point_builder.new(1, 2))
      end
    end

    context "Affine transformations" do
      let(:input_point) { point_builder.new(3, 4) }
      let(:expected_point) { point_builder.new(4, 6) }
      subject { Vector.new(1, 2, world) }

      include_examples "producing a transform-compatible version of itself"
    end
  end
end
