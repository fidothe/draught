require 'draught/boxlike_examples'
require 'draught/point'
require 'draught/path'

module Draught
  RSpec.describe Path do
    let(:point) { Point.new(1,1) }

    it "contains no points by default" do
      expect(subject.empty?).to be(true)
    end

    it "can be initialized with an array of Points" do
      path = Path.new([point])

      expect(path.empty?).to be(false)
    end

    it "can return an array of its points" do
      path = Path.new([point])

      expect(path.points).to eq([point])
    end

    specify "appending a point to the path returns a new path" do
      path = subject.append(point)

      expect(path.points).to eq([point])
      expect(subject).to be_empty
    end

    specify "appending several points to the path returns a new path" do
      other_point = Point.new(2,2)

      path = subject.append(point, other_point)

      expect(path.points).to eq([point, other_point])
    end

    it "appending another path returns a new path with the other path's points appended" do
      other_point = Point.new(2,2)
      first_path = Path.new([point])
      other_path = Path.new([other_point])

      path = first_path << other_path

      expect(path.points).to eq([point, other_point])
    end

    it "can return the last point in the path" do
      path = Path.new([point])

      expect(path.last).to be(point)
    end

    it "can return the number of points in the path" do
      path = Path.new([point])

      expect(path.length).to eq(1)
    end

    describe "equality" do
      let(:p1) { Point.new(1,1) }
      let(:p2) { Point.new(1,2) }
      let(:p3) { Point.new(2,1) }

      subject { Path.new([p1, p2]) }

      it "compares two Paths equal if all their Points are equal" do
        path = Path.new([p1, p2])

        expect(subject == path).to be(true)
      end

      it "compares two Paths unequal if one has a different number of Points" do
        path = subject << p3

        expect(subject == path).to be(false)
      end

      it "compares two Paths unequal if one or more of their Points are not equal" do
        path = Path.new([p1, p3])

        expect(subject == path).to be(false)
      end
    end

    describe "information about extent" do
      subject { Path.new([Point.new(1,4), Point.new(5,2)]) }

      it_should_behave_like "a basic rectangular box-like thing"

      context "an empty path" do
        subject { Path.new }

        it "returns (0,0) for lower left" do
          expect(subject.lower_left).to eq(Point.new(0,0))
        end

        it "returns (0,0) for lower right" do
          expect(subject.upper_right).to eq(Point.new(0,0))
        end
      end
    end

    describe "translation and transformation" do
      let(:p1) { Point.new(1,1) }
      let(:p2) { Point.new(1,2) }
      let(:p3) { Point.new(2,1) }

      subject { Path.new([p1, p2]) }

      specify "translating a Path using a Point produces a new Path with appropriately translated Points" do
        expected = Path.new([Point.new(3,2), Point.new(3,3)])

        expect(subject.translate(p3)).to eq(expected)
      end

      specify "transforming a Path generates a new Path by applying the transformation to every Point in the Path" do
        transformation = Matrix[[2,0,0],[0,2,0],[0,0,1]]
        expected = Path.new([Point.new(2,2), Point.new(2,4)])

        expect(subject.transform(transformation)).to eq(expected)
      end
    end

    it "returns an Array of itself for #paths" do
      expect(subject.paths).to eq([subject])
    end

    it "returns an empty Array for #containers" do
      expect(subject.containers).to eq([])
    end
  end
end
