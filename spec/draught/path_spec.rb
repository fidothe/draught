require 'draught/world'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'
require 'draught/extent_examples'
require 'draught/point'
require 'draught/vector'
require 'draught/transformations'
require 'draught/path'

module Draught
  RSpec.describe Path do
    let(:world) { World.new }
    let(:points) { [world.point(1,1), world.point(1,2)] }
    let(:metadata) { Metadata::Instance.new(name: 'name') }

    it "contains no points by default" do
      expect(Path.new(world).empty?).to be(true)
    end

    it "can be initialized with an array of points" do
      path = Path.new(world, points: points)

      expect(path.empty?).to be(false)
    end

    describe "metadata" do
      it "can be initialized with a Metadata" do
        path = Path.new(world, points: points, metadata: metadata)

        expect(path.metadata).to be(metadata)
      end

      specify "has a blank Metadata by default" do
        expect(Path.new(world).metadata).to be(Metadata::BLANK)
      end
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.new(world, points: points) }
      let(:lower_left) { world.point(1,1) }
      let(:upper_right) { world.point(1,2) }
    end

    it_should_behave_like "a pathlike thing" do
      subject { Path.new(world, points: points) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { Path.new(world, points: points) }
    end

    describe "adding points to the path" do
      subject { Path.new(world, points: points, metadata: metadata) }

      context "appending" do
        specify "appending a point to the path returns a new path" do
          path = subject.append(world.point(2,2))

          expect(path.points).to eq([world.point(1,1), world.point(1,2), world.point(2,2)])
        end

        specify "appending several points to the path returns a new path" do
          path = subject.append(world.point(2,2), world.point(2,3))

          expect(path.points).to eq([world.point(1,1), world.point(1,2), world.point(2,2), world.point(2,3)])
        end

        it "appending another path returns a new path with the other path's points appended" do
          other_path = Path.new(world, points: [world.point(2,2)])

          path = subject.append(other_path)

          expect(path.points).to eq([world.point(1,1), world.point(1,2), world.point(2,2)])
        end

        specify "appending preserves metadata" do
          path = subject.append(world.point(2,2))

          expect(path.metadata).to be(metadata)
        end
      end

      context "prepending" do
        specify "prepending a point to the path returns a new path" do
          path = subject.prepend(world.point(2,2))

          expect(path.points).to eq([world.point(2,2), world.point(1,1), world.point(1,2)])
        end

        specify "prepending several points to the path returns a new path" do
          path = subject.prepend(world.point(2,2), world.point(2,3))

          expect(path.points).to eq([world.point(2,2), world.point(2,3), world.point(1,1), world.point(1,2)])
        end

        it "prepending another path returns a new path with the other path's points prepended" do
          other_path = Path.new(world, points: [world.point(2,2), world.point(2,3)])

          path = subject.prepend(other_path)

          expect(path.points).to eq([world.point(2,2), world.point(2,3), world.point(1,1), world.point(1,2)])
        end

        specify "prepending preserves metadata" do
          path = subject.prepend(world.point(2,2))

          expect(path.metadata).to be(metadata)
        end
      end
    end

    describe "being enumerable enough" do
      subject { Path.new(world, points: [world.point(1,1), world.point(1,2), world.point(1,3)]) }

      context "[] access" do
        it "can also retrieve a slice via range" do
          expect(subject[1..2]).to eq(Path.new(world, points: [world.point(1,2), world.point(1,3)]))
        end

        it "can also retrieve a slice via (n,n) args" do
          expect(subject[0,2]).to eq(Path.new(world, points: [world.point(1,1), world.point(1,2)]))
        end
      end
    end

    describe "comparison" do
      subject { Path.new(world, points: [world.point(1,1), world.point(1,2)]) }

      context "equality" do
        it "compares two Paths equal if all their Points are equal" do
          path = Path.new(world, points: [world.point(1,1), world.point(1,2)])

          expect(subject == path).to be(true)
        end

        it "compares two Paths unequal if one has different Subpaths" do
          path = Path.new(world, points: [world.point(1,1)])

          expect(subject == path).to be(false)
        end
      end
    end

    describe "an empty path" do
      context "extent" do
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
        expect(Path.new(world, points: [p1])).to pp_as("(P 1,1)\n")
      end

      specify "a path containing multiple points returns a sensible string" do
        expect(Path.new(world, points: [p1, p2])).to pp_as("(P 1,1 1,2)\n")
      end
    end
  end
end
