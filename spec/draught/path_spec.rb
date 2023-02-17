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
    let(:subpath) { Draught::Subpath.new(world, points: [world.point(1,1), world.point(1,2)]) }
    let(:other_subpath) { Draught::Subpath.new(world, points: [world.point(2,2), world.point(2,3)]) }
    let(:other_subpath_2) { Draught::Subpath.new(world, points: [world.point(3,3), world.point(3,4)]) }
    let(:metadata) { Metadata::Instance.new(name: 'name') }

    it "contains no subpaths by default" do
      expect(Path.new(world).empty?).to be(true)
    end

    it "can be initialized with an array of Subpaths" do
      path = Path.new(world, subpaths: [subpath])

      expect(path.empty?).to be(false)
    end

    describe "metadata" do
      it "can be initialized with a Metadata" do
        path = Path.new(world, subpaths: [subpath], metadata: metadata)

        expect(path.metadata).to be(metadata)
      end

      specify "has a blank Metadata by default" do
        expect(Path.new(world).metadata).to be(Metadata::BLANK)
      end
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.new(world, subpaths: [subpath]) }
      let(:lower_left) { world.point(1,1) }
      let(:upper_right) { world.point(1,2) }
    end

    it_should_behave_like "a pathlike thing" do
      subject { Path.new(world, subpaths: subpaths) }
      let(:subpaths) { [subpath, other_subpath] }
      let(:subpaths_points) { subpaths.map(&:points) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { Path.new(world, subpaths: [subpath, other_subpath]) }
    end

    describe "adding subpaths to the path" do
      subject { Path.new(world, subpaths: [subpath], metadata: metadata) }

      context "appending" do
        specify "appending a subpath to the path returns a new path" do
          path = subject.append(other_subpath)

          expect(path.subpaths).to eq([subpath, other_subpath])
          expect(subject.subpaths).to eq([subpath])
        end

        specify "appending several subpaths to the path returns a new path" do
          path = subject.append(other_subpath, other_subpath_2)

          expect(path.subpaths).to eq([subpath, other_subpath, other_subpath_2])
        end

        it "appending another path returns a new path with the other path's subpaths appended" do
          other_path = Path.new(world, subpaths: [other_subpath])

          path = subject << other_path

          expect(path.subpaths).to eq([subpath, other_subpath])
        end

        specify "appending preserves metadata" do
          path = subject.append(other_subpath)

          expect(path.metadata).to be(metadata)
        end
      end

      context "prepending" do
        specify "prepending a subpath to the path returns a new path" do
          path = subject.prepend(other_subpath)

          expect(path.subpaths).to eq([other_subpath, subpath])
          expect(subject.subpaths).to eq([subpath])
        end

        specify "prepending several subpaths to the path returns a new path" do
          path = subject.prepend(other_subpath, other_subpath_2)

          expect(path.subpaths).to eq([other_subpath, other_subpath_2, subpath])
        end

        it "prepending another path returns a new path with the other path's subpaths prepended" do
          other_path = Path.new(world, subpaths: [other_subpath, other_subpath_2])

          path = subject.prepend(other_path)

          expect(path.subpaths).to eq([other_subpath, other_subpath_2, subpath])
        end

        specify "prepending preserves metadata" do
          path = subject.prepend(other_subpath)

          expect(path.metadata).to be(metadata)
        end
      end
    end

    describe "being enumerable enough" do
      subject { Path.new(world, subpaths: [subpath, other_subpath, other_subpath_2]) }

      context "[] access" do
        it "can also retrieve a slice via range" do
          expect(subject[1..2]).to eq(Path.new(world, subpaths: [other_subpath, other_subpath_2]))
        end

        it "can also retrieve a slice via (n,n) args" do
          expect(subject[0,2]).to eq(Path.new(world, subpaths: [subpath, other_subpath]))
        end
      end
    end

    describe "comparison" do
      let(:subpath_1) { Draught::Subpath.new(world, points: [world.point(1,1), world.point(1,2)]) }
      let(:subpath_2) { Draught::Subpath.new(world, points: [world.point(1,1), world.point(2,2)]) }

      subject { Path.new(world, subpaths: [subpath_1]) }

      context "equality" do
        it "compares two Paths equal if all their Points are equal" do
          path = Path.new(world, subpaths: [subpath_1])

          expect(subject == path).to be(true)
        end

        it "compares two Paths unequal if one has different Subpaths" do
          path = Path.new(world, subpaths: [subpath_2])

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
        expect(Path.new(world, subpaths: [subpath])).to pp_as("(P (1,1 1,2))\n")
      end

      specify "a path containing multiple points returns a sensible string" do
        expect(Path.new(world, subpaths: [subpath, other_subpath])).to pp_as("(P (1,1 1,2) (2,2 2,3))\n")
      end
    end
  end
end
