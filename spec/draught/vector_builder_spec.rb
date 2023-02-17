require 'draught/vector_builder'
require 'draught/world'

module Draught
  RSpec.describe VectorBuilder do
    let(:world) { World.new }
    let(:point_builder) { world.point }
    let(:radians) { Math.atan(4/3.0) }
    let(:degrees) { radians * (180.0 / Math::PI) }

    subject { VectorBuilder.new(world) }

    specify "can generate a Vector" do
      vector = subject.build(1,2)
      expect(vector.x).to eq(1)
      expect(vector.y).to eq(2)
      expect(vector.world).to be(world)
    end

    specify "provides a null (0,0) vector via a method" do
      expect(subject.null).to eq(subject.build(0,0))
    end

    it "can create from an x,y pair" do
      vector = subject.from_xy(3,4)
      expect(vector.x).to eq(3)
      expect(vector.y).to eq(4)
    end

    it "can create from a direction in radians and a magnitude" do
      vector = subject.from_radians_and_magnitude(radians, 5)

      expect(vector.x).to be_within(0.00001).of(3)
      expect(vector.y).to be_within(0.00001).of(4)
    end

    it "can create from a direction in degrees and a magnitude" do
      vector = subject.from_degrees_and_magnitude(degrees, 5)

      expect(vector.x).to be_within(0.00001).of(3)
      expect(vector.y).to be_within(0.00001).of(4)
    end

    context "directions which result in negative cartesian co-ords" do
      it "copes with reflected-x" do
        vector = subject.from_degrees_and_magnitude(180 - degrees, 5)

        expect(vector.x).to be_within(0.00001).of(-3)
        expect(vector.y).to be_within(0.00001).of(4)
      end

      it "copes with reflected-y" do
        vector = subject.from_degrees_and_magnitude(360 - degrees, 5)

        expect(vector.x).to be_within(0.00001).of(3)
        expect(vector.y).to be_within(0.00001).of(-4)
      end

      it "copes with reflected x and y" do
        vector = subject.from_degrees_and_magnitude(180 + degrees, 5)

        expect(vector.x).to be_within(0.00001).of(-3)
        expect(vector.y).to be_within(0.00001).of(-4)
      end
    end

    context "relationships between points" do
      it "can construct a vector representing the translation between two points" do
        p1 = point_builder.new(1,2)
        p2 = point_builder.new(3,1)

        expect(subject.translation_between(p1, p2)).to eq(subject.build(2,-1))
      end

      it "can construct a vector representing the translation between a point and (0,0)" do
        expect(subject.translation_to_zero(point_builder.new(1,2))).to eq(subject.build(-1,-2))
      end
    end
  end
end
