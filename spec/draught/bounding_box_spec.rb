require 'draught/boxlike_examples'
require 'draught/bounding_box'
require 'draught/transformations'
require 'draught/path'
require 'draught/vector'

module Draught
  RSpec.describe BoundingBox do
    let(:input_path) { Path.new([Point.new(-1, -1), Point.new(3,3)]) }
    let(:zeroed_path) { Path.new([Point.new(0, 0), Point.new(4,4)]) }
    let(:zeroed) { BoundingBox.new(zeroed_path) }
    subject { BoundingBox.new(input_path) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "can return its paths" do
      expect(subject.paths).to eq([input_path])
    end

    describe "equality" do
      it "compares equal if the other box has the same paths in the same order" do
        expect(BoundingBox.new(input_path)).to eq(subject)
      end

      it "does not compare equal if the other box has the same paths in a different order" do
       reversed_path = Path.new(input_path.points.reverse)
        reversed = BoundingBox.new(reversed_path)

        expect(reversed).to_not eq(subject)
      end

      it "does not compare equal if the other box does not have the same paths" do
        truncated_path = Path.new(input_path.points[0..0])
        truncated = BoundingBox.new(truncated_path)

        expect(truncated).to_not eq(subject)
      end
    end

    describe "manipulations in space" do
      let(:input_path) { Path.new([Point.new(-1, -1), Point.new(3,3)]) }
      subject { BoundingBox.new(input_path) }

      it "can be translated" do
        expected = BoundingBox.new(Path.new([Point.new(0,-1), Point.new(4,3)]))

        translated = subject.translate(Vector.new(1,0))

        expect(translated).to eq(expected)
      end

      it "can be transformed" do
        transformation = Draught::Transformations::Affine.new(
          Matrix[[2,0,0],[0,2,0],[0,0,1]]
        )
        expected = BoundingBox.new(Path.new([Point.new(-2,-2), Point.new(6,6)]))

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
