require 'draught/path_builder'
require 'draught/line'

module Draught
  RSpec.describe Line do
    describe "generating horizontal lines" do
      specify "a line of width N is a Path with points at (0,0) and (N,0)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(10, 0) }

        expect(Line.horizontal(10)).to eq(expected)
      end
    end

    describe "generating vertical lines" do
      specify "a line of height N is a Path with points at (0,0) and (0,N)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(0, 10) }

        expect(Line.vertical(10)).to eq(expected)
      end
    end
  end
end
