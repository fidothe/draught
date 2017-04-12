require 'draught/vector'
require 'draught/point'
require 'draught/transformations/shared_examples'

module Draught
  RSpec.describe Vector do
    let(:radians) { Math.atan(4/3.0) }
    let(:degrees) { radians * (180.0 / Math::PI) }

    it "can be created from an x,y pair" do
      vector = Vector.from_xy(3,4)
      expect(vector.x).to eq(3)
      expect(vector.y).to eq(4)
    end

    it "can be created from a direction in degrees and a magnitude" do
      vector = Vector.from_degrees_and_magnitude(degrees, 5)

      expect(vector.x).to be_within(0.00001).of(3)
      expect(vector.y).to be_within(0.00001).of(4)
    end

    it "can be created from a direction in radians and a magnitude" do
      vector = Vector.from_radians_and_magnitude(radians, 5)

      expect(vector.x).to be_within(0.00001).of(3)
      expect(vector.y).to be_within(0.00001).of(4)
    end

    specify "provides a (0,0) vector via a constant" do
      expect(Vector::NULL).to eq(Vector.new(0,0))
    end

    context "directions which result in negative cartesian co-ords" do
      it "copes with reflected-x" do
        vector = Vector.from_degrees_and_magnitude(180 - degrees, 5)

        expect(vector.x).to be_within(0.00001).of(-3)
        expect(vector.y).to be_within(0.00001).of(4)
      end

      it "copes with reflected-y" do
        vector = Vector.from_degrees_and_magnitude(360 - degrees, 5)

        expect(vector.x).to be_within(0.00001).of(3)
        expect(vector.y).to be_within(0.00001).of(-4)
      end

      it "copes with reflected x and y" do
        vector = Vector.from_degrees_and_magnitude(180 + degrees, 5)

        expect(vector.x).to be_within(0.00001).of(-3)
        expect(vector.y).to be_within(0.00001).of(-4)
      end
    end

    context "comparison" do
      subject { Vector.new(1,2) }

      it "compares equal to another vector with the same x, y" do
        expect(subject).to eq(Vector.new(1,2))
      end

      it "does not compare equal to a Point with the same x, y" do
        expect(subject).not_to eq(Point.new(1,2))
      end
    end

    context "Affine transformations" do
      let(:input_point) { Point.new(3, 4) }
      let(:expected_point) { Point.new(4, 6) }
      subject { Vector.new(1, 2) }

      include_examples "producing a transform-compatible version of itself"
    end

    context "relationships between points" do
      it "can construct a vector representing the translation between two points" do
        p1 = Point.new(1,2)
        p2 = Point.new(3,1)

        expect(Vector.translation_between(p1, p2)).to eq(Vector.new(2,-1))
      end
    end
  end
end
