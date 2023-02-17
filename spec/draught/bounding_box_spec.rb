require 'draught/boxlike_examples'
require 'draught/bounding_box'
require 'draught/world'
require 'draught/transformations'

module Draught
  RSpec.describe BoundingBox do
    let(:world) { World.new }
    let(:input_path) { world.path.simple(points: [world.point.new(-1, -1), world.point.new(3,3)]) }
    let(:zeroed_path) { world.path.simple(points: [world.point.zero, world.point.new(4,4)]) }
    let(:zeroed) { BoundingBox.new(world, [zeroed_path]) }
    subject { BoundingBox.new(world, [input_path]) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "can return its paths" do
      expect(subject.paths).to eq([input_path])
    end

    it "returns [:container] for #box_type" do
      expect(subject.box_type).to eq([:container])
    end

    describe "equality" do
      subject { BoundingBox.new(world, [input_path, zeroed_path]) }

      it "compares equal if the other box has the same paths in the same order" do
        expect(BoundingBox.new(world, [input_path, zeroed_path])).to eq(subject)
      end

      it "does not compare equal if the other box has the same paths in a different order" do
        reversed = BoundingBox.new(world, [zeroed_path, input_path])

        expect(reversed).to_not eq(subject)
      end

      it "does not compare equal if the other box does not have the same paths" do
        truncated = BoundingBox.new(world, [zeroed_path])

        expect(truncated).to_not eq(subject)
      end
    end

    describe "manipulations in space" do
      let(:input_path) { world.path.simple(points: [world.point.new(-1, -1), world.point.new(3,3)]) }
      subject { BoundingBox.new(world, [input_path]) }

      it "can be translated" do
        expected = BoundingBox.new(world, [world.path.simple(points: [world.point.new(0,-1), world.point.new(4,3)])])

        translated = subject.translate(world.vector.new(1,0))

        expect(translated).to eq(expected)
      end

      it "can be transformed" do
        transformation = Draught::Transformations::Affine.new(
          Matrix[[2,0,0],[0,2,0],[0,0,1]]
        )
        expected = BoundingBox.new(world, [world.path.simple(points: [world.point.new(-2,-2), world.point.new(6,6)])])

        transformed = subject.transform(transformation)

        expect(transformed).to eq(expected)
      end
    end

    describe "returning a new box translated so its origin is at 0,0" do
      it "correctly translates its paths" do
        expect(subject.zero_origin).to eq(zeroed)
      end

      it "zeroing an already-at-zero box simply returns self" do
        expect(zeroed.zero_origin).to be(zeroed)
      end
    end
  end
end
