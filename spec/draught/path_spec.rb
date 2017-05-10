require 'draught/boxlike_examples'
require 'draught/pathlike_examples'
require 'draught/point'
require 'draught/vector'
require 'draught/transformations'
require 'draught/path'

module Draught
  RSpec.describe Path do
    let(:point) { Point.new(1,1) }
    let(:other_point) { Point.new(2,2) }

    it "contains no points by default" do
      expect(Path.new.empty?).to be(true)
    end

    it "can be initialized with an array of Points" do
      path = Path.new([point])

      expect(path.empty?).to be(false)
    end

    it_should_behave_like "a pathlike thing" do
      subject { Path.new([point, other_point]) }
      let(:points) { [point, other_point] }
    end

    describe "adding points to the path" do
      subject { Path.new([point]) }

      context "appending" do
        specify "appending a point to the path returns a new path" do
          path = subject.append(other_point)

          expect(path.points).to eq([point, other_point])
          expect(subject.points).to eq([point])
        end

        specify "appending several points to the path returns a new path" do
          path = subject.append(point, other_point)

          expect(path.points).to eq([point, point, other_point])
        end

        it "appending another path returns a new path with the other path's points appended" do
          other_path = Path.new([other_point])

          path = subject << other_path

          expect(path.points).to eq([point, other_point])
        end
      end

      context "prepending" do
        specify "prepending a point to the path returns a new path" do
          path = subject.prepend(other_point)

          expect(path.points).to eq([other_point, point])
          expect(subject.points).to eq([point])
        end

        specify "prepending several points to the path returns a new path" do
          path = subject.prepend(other_point, other_point)

          expect(path.points).to eq([other_point, other_point, point])
        end

        it "prepending another path returns a new path with the other path's points appended" do
          other_path = Path.new([other_point])

          path = subject.prepend(other_path)

          expect(path.points).to eq([other_point, point])
        end
      end
    end

    describe "being enumerable enough" do
      let(:p1) { Point.new(1,1) }
      let(:p2) { Point.new(1,2) }
      let(:p3) { Point.new(2,1) }

      subject { Path.new([p1, p2, p3]) }

      context "[] access" do
        it "can also retrieve a slice via range" do
          expect(subject[1..2]).to eq(Path.new([p2, p3]))
        end

        it "can also retrieve a slice via (n,n) args" do
          expect(subject[0,2]).to eq(Path.new([p1, p2]))
        end
      end
    end

    describe "comparison" do
      let(:p1) { Point.new(1,1) }
      let(:p2) { Point.new(1,2) }
      let(:p3) { Point.new(2,1) }

      subject { Path.new([p1, p2]) }

      context "equality" do
        it "compares two Paths equal if all their Points are equal" do
          path = Path.new([p1, p2])

          expect(subject == path).to be(true)
        end

        it "compares two Paths unequal if one has a different number of Points" do
          path = subject << p3

          expect(subject == path).to be(false)
        end
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
  end
end
