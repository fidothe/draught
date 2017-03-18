require 'draught/path_cleaner'
require 'draught/point'

module Draught
  RSpec.describe PathCleaner do
    def p(x, y)
      Point.new(x, y)
    end

    it "can remove extra identical points and returns a new cleaned path" do
      input = Path.new([p(0,0), p(1,0), p(1,0), p(4,0)])
      expected = Path.new([p(0,0), p(1,0), p(4,0)])

      expect(PathCleaner.dedupe(input)).to eq(expected)
    end

    describe "simplifying a path" do
      let(:expected) { Path.new([p(0,0), p(4,0), p(4,4)]) }

      it "removes unnecessary intermediate points on the horizontal" do
        input = Path.new([p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the horizontal" do
        input = Path.new([p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the vertical" do
        input = Path.new([p(0,0), p(4,0), p(4,1), p(4,2), p(4,4)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "goes around corners" do
        input = Path.new([p(0,0), p(1,0), p(3,0), p(4,0), p(4,2), p(4,4)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "does not remove points where it's not obvious which point to remove" do
        input = Path.new([p(0,0), p(4,0), p(1,0)])
        expected = Path.new([p(0,0), p(4,0), p(1,0)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "copes with paths proceeding right-to-left" do
        input = Path.new([p(4,0), p(2,0), p(1,0)])
        expected = Path.new([p(4,0), p(1,0)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end

      it "copes with paths proceeding top-to-bottom" do
        input = Path.new([p(0,4), p(0,2), p(0,1)])
        expected = Path.new([p(0,4), p(0,1)])

        expect(PathCleaner.simplify(input)).to eq(expected)
      end
    end
  end
end
