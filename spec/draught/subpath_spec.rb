require 'draught/world'
require 'draught/pathlike_examples'
require 'draught/extent_examples'
require 'draught/point'
require 'draught/vector'
require 'draught/transformations'
require 'draught/subpath'

module Draught
  RSpec.describe Subpath do
    let(:world) { World.new }
    let(:point) { world.point(1,1) }
    let(:other_point) { world.point(2,2) }

    it "contains no points by default" do
      expect(described_class.new(world).empty?).to be(true)
    end

    it "can be initialized with an array of Points" do
      subpath = described_class.new(world, points: [point])

      expect(subpath.empty?).to be(false)
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.new(world, points: [world.point(1,1), world.point(2,2)]) }
      let(:lower_left) { world.point(1,1) }
      let(:upper_right) { world.point(2,2) }
    end

    describe "adding points to the subpath" do
      subject { described_class.new(world, points: [point]) }

      context "appending" do
        specify "appending an array of points to the subpath returns a new subpath" do
          subpath = subject.append([other_point])

          expect(subpath.points).to eq([point, other_point])
          expect(subject.points).to eq([point])
        end

        specify "appending several points to the subpath returns a new subpath" do
          subpath = subject.append([point, other_point])

          expect(subpath.points).to eq([point, point, other_point])
        end

        it "appending another subpath returns a new subpath with the other subpath's points appended" do
          other_subpath = described_class.new(world, points: [other_point])

          subpath = subject << other_subpath

          expect(subpath.points).to eq([point, other_point])
        end
      end

      context "prepending" do
        specify "prepending a point to the subpath returns a new subpath" do
          subpath = subject.prepend([other_point])

          expect(subpath.points).to eq([other_point, point])
          expect(subject.points).to eq([point])
        end

        specify "prepending several points to the subpath returns a new subpath" do
          subpath = subject.prepend([other_point, other_point])

          expect(subpath.points).to eq([other_point, other_point, point])
        end

        it "prepending another subpath returns a new subpath with the other subpath's points appended" do
          other_subpath = described_class.new(world, points: [other_point])

          subpath = subject.prepend([other_subpath])

          expect(subpath.points).to eq([other_point, point])
        end
      end
    end

    describe "being enumerable enough" do
      let(:p1) { world.point(1,1) }
      let(:p2) { world.point(1,2) }
      let(:p3) { world.point(2,1) }

      subject { described_class.new(world, points: [p1, p2, p3]) }

      context "[] access" do
        it "can also retrieve a slice via range" do
          expect(subject[1..2]).to eq(described_class.new(world, points: [p2, p3]))
        end

        it "can also retrieve a slice via (n,n) args" do
          expect(subject[0,2]).to eq(described_class.new(world, points: [p1, p2]))
        end
      end
    end

    specify "returns an array of itself when asked for #subpaths" do
      subpath = described_class.new(world)
      expect(subpath.subpaths).to eq([subpath])
    end


    describe "comparison" do
      let(:p1) { world.point(1,1) }
      let(:p2) { world.point(1,2) }
      let(:p3) { world.point(2,1) }

      subject { described_class.new(world, points: [p1, p2]) }

      context "equality" do
        it "compares two Subpaths equal if all their Points are equal" do
          subpath = described_class.new(world, points: [p1, p2])

          expect(subject == subpath).to be(true)
        end

        it "compares two Subpaths unequal if one has a different number of Points" do
          subpath = subject << p3

          expect(subject == subpath).to be(false)
        end
      end
    end

    describe "information about extent" do
      context "an empty subpath" do
        subject { described_class.new(world) }

        it "returns (0,0) for lower left" do
          expect(subject.lower_left).to eq(world.point(0,0))
        end

        it "returns (0,0) for lower right" do
          expect(subject.upper_right).to eq(world.point(0,0))
        end
      end
    end

    describe "Pretty printing" do
      let(:p1) { world.point(1,1) }
      let(:p2) { world.point(1,2) }

      specify "an empty subpath returns a sensible string" do
        expect(described_class.new(world)).to pp_as("()\n")
      end

      specify "an one-point subpath returns a sensible string" do
        expect(described_class.new(world, points: [p1])).to pp_as("(1,1)\n")
      end

      specify "a subpath containing multiple points returns a sensible string" do
        expect(described_class.new(world, points: [p1, p2])).to pp_as("(1,1 1,2)\n")
      end
    end
  end
end
