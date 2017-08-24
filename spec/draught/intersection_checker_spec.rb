require 'draught/intersection_checker'
require 'draught/line_segment'

module Draught
  RSpec.describe IntersectionChecker do
    describe "line/line intersections" do
      let(:l1) { LineSegment.build(start_point: Point.new(0,2), end_point: Point.new(4,2)) }
      let(:l2) { LineSegment.build(start_point: Point.new(2,0), end_point: Point.new(2,4)) }
      let(:l3) { LineSegment.build(start_point: Point.new(0,0), end_point: Point.new(4,0)) }
      let(:l4) { LineSegment.build(start_point: Point.new(0,0), end_point: Point.new(2,1)) }
      let(:wonky_point) { Point.new(4.0000000001, 2) }
      let(:l5) { LineSegment.build(start_point: Point.new(2,0), end_point: wonky_point)}

      it "knows that l1 and l2 insersect at (2,2)" do
        expect(IntersectionChecker.check(l1, l2)).to eq([Point.new(2,2)])
      end

      it "knows that l1 and l3 don't insersect" do
        expect(IntersectionChecker.check(l1, l3)).to eq([])
      end

      it "knows that l1 and l4 don't intersect" do
        expect(IntersectionChecker.check(l1, l4)).to eq([])
      end

      xit "knows that l1 and l5 should intersect, despite the tiny discrepancy" do
        expect(IntersectionChecker.check(l1, l5)).to eq([wonky_point])
      end
    end
  end
end
