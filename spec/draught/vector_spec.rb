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

    def v(x, y)
      Vector.new(x, y, world)
    end

    def p(x, y)
      world.point.new(x, y)
    end

    context "comparison" do
      subject { Vector.new(1, 2, world) }

      it "compares equal to another vector with the same x, y" do
        expect(subject).to eq(Vector.new(1, 2, world))
      end

      it "does not compare equal to a Point with the same x, y" do
        expect(subject).not_to eq(p(1, 2))
      end
    end

    context "vector addition and subtraction" do
      subject { v(1, 2) }
      let(:v1) { v(2, 2) }

      specify "Vectors can be added" do
        expect(subject + v1).to eq(v(3,4))
      end

      specify "Vectors can be subtracted" do
        expect(subject - v1).to eq(v(-1,0))
      end

      specify "cannot be added to a point" do
        expect { subject + p(1,1) }.to raise_error(ArgumentError)
      end
    end

    context "Affine transformations" do
      let(:input_point) { p(3, 4) }
      let(:expected_point) { p(4, 6) }
      subject { v(1, 2) }

      include_examples "producing a transform-compatible version of itself"
    end
  end
end
