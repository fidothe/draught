require 'draught/path_intersection_point'
require 'draught/world'

module Draught
  RSpec.describe PathIntersectionPoint do
    let(:world) { World.new }
    let(:path_1) { world.path.simple(world.point.zero, world.point(10,10)) }
    let(:path_2) { world.path.simple(world.point(0,10), world.point(10,0)) }
    let(:point) { world.point(5,5) }

    subject { described_class.new(world, point, [path_1, path_2]) }

    it "returns its x" do
      expect(subject.x).to eq(point.x)
    end

    it "returns its y" do
      expect(subject.y).to eq(point.y)
    end

    specify "returns its paths" do
      expect(subject.paths).to eq([path_1, path_2])
    end

    specify "returns its point" do
      expect(subject.point).to be(point)
    end

    describe "comparing equal" do
      specify "when it has the same point and same paths as another succeeds" do
        other = described_class.new(world, point, [path_1, path_2])

        expect(subject).to eq(other)
      end

      specify "when it has the same point but different paths as another does not succeed" do
        other = described_class.new(world, point, [])

        expect(subject).not_to eq(other)
      end
    end

    describe "pretty printing" do
      specify "a point generates a simple x,y string" do
        expect(subject).to pp_as("5,5\n")
      end
    end
  end
end
