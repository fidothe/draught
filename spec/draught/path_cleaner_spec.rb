require 'draught/path_cleaner'
require 'draught/world'

module Draught
  RSpec.describe PathCleaner do
    let(:world) { World.new }
    def p(x, y)
      world.point.new(x, y)
    end

    it "can remove extra identical points and returns a new cleaned path" do
      input = world.path.new([p(0,0), p(1,0), p(1,0), p(4,0)])
      expected = world.path.new([p(0,0), p(1,0), p(4,0)])

      expect(PathCleaner.dedupe(world, input)).to eq(expected)
    end

    describe "simplifying a path" do
      let(:expected) { world.path.new([p(0,0), p(4,0), p(4,4)]) }

      it "removes unnecessary intermediate points on the horizontal" do
        input = world.path.new([p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the horizontal" do
        input = world.path.new([p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the vertical" do
        input = world.path.new([p(0,0), p(4,0), p(4,1), p(4,2), p(4,4)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "goes around corners" do
        input = world.path.new([p(0,0), p(1,0), p(3,0), p(4,0), p(4,2), p(4,4)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "does not remove points where it's not obvious which point to remove" do
        input = world.path.new([p(0,0), p(4,0), p(1,0)])
        expected = world.path.new([p(0,0), p(4,0), p(1,0)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "copes with paths proceeding right-to-left" do
        input = world.path.new([p(4,0), p(2,0), p(1,0)])
        expected = world.path.new([p(4,0), p(1,0)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end

      it "copes with paths proceeding top-to-bottom" do
        input = world.path.new([p(0,4), p(0,2), p(0,1)])
        expected = world.path.new([p(0,4), p(0,1)])

        expect(PathCleaner.simplify(world, input)).to eq(expected)
      end
    end
  end
end
