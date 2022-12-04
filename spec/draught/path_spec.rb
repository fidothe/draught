require 'draught/world'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'
require 'draught/point'
require 'draught/vector'
require 'draught/transformations'
require 'draught/path'

module Draught
  RSpec.describe Path do
    let(:world) { World.new }
    let(:point) { world.point.new(1,1) }
    let(:other_point) { world.point.new(2,2) }

    it "contains no points by default" do
      expect(Path.new(world).empty?).to be(true)
    end

    it "can be initialized with an array of Points" do
      path = Path.new(world, [point])

      expect(path.empty?).to be(false)
    end

    it_should_behave_like "a pathlike thing" do
      subject { Path.new(world, [point, other_point]) }
      let(:points) { [point, other_point] }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { Path.new(world, [point, other_point]) }
    end

    describe "adding points to the path" do
      subject { Path.new(world, [point]) }

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
          other_path = Path.new(world, [other_point])

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
          other_path = Path.new(world, [other_point])

          path = subject.prepend(other_path)

          expect(path.points).to eq([other_point, point])
        end
      end
    end

    describe "being enumerable enough" do
      let(:p1) { world.point.new(1,1) }
      let(:p2) { world.point.new(1,2) }
      let(:p3) { world.point.new(2,1) }

      subject { Path.new(world, [p1, p2, p3]) }

      context "[] access" do
        it "can also retrieve a slice via range" do
          expect(subject[1..2]).to eq(Path.new(world, [p2, p3]))
        end

        it "can also retrieve a slice via (n,n) args" do
          expect(subject[0,2]).to eq(Path.new(world, [p1, p2]))
        end
      end
    end

    describe "comparison" do
      let(:p1) { world.point.new(1,1) }
      let(:p2) { world.point.new(1,2) }
      let(:p3) { world.point.new(2,1) }

      subject { Path.new(world, [p1, p2]) }

      context "equality" do
        it "compares two Paths equal if all their Points are equal" do
          path = Path.new(world, [p1, p2])

          expect(subject == path).to be(true)
        end

        it "compares two Paths unequal if one has a different number of Points" do
          path = subject << p3

          expect(subject == path).to be(false)
        end
      end
    end

    describe "information about extent" do
      context "an empty path" do
        subject { Path.new(world) }

        it "returns (0,0) for lower left" do
          expect(subject.lower_left).to eq(world.point.new(0,0))
        end

        it "returns (0,0) for lower right" do
          expect(subject.upper_right).to eq(world.point.new(0,0))
        end
      end
    end

    describe "Pretty printing" do
      let(:p1) { world.point.new(1,1) }
      let(:p2) { world.point.new(1,2) }

      specify "an empty path returns a sensible string" do
        expect(Path.new(world)).to pp_as("(P)\n")
      end

      specify "an one-point path returns a sensible string" do
        expect(Path.new(world, [p1])).to pp_as("(P 1,1)\n")
      end

      specify "a path containing multiple points returns a sensible string" do
        expect(Path.new(world, [p1, p2])).to pp_as("(P 1,1 1,2)\n")
      end
    end
  end
end
