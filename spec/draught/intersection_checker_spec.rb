require 'draught/intersection_checker'
require 'draught/line_segment'
require 'draught/curve_segment'

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

    describe "curve/line intersections" do
      let(:l1) { LineSegment.build(start_point: Point.new(0,100), end_point: Point.new(100,100)) }
      let(:c1) { CurveSegment.build({
        start_point: Point.new(0,75), cubic_bezier: CubicBezier.new({
          end_point: Point.new(100,80), control_point_1: Point.new(50,200),
          control_point_2: Point.new(50,205)
        })
      }) }

      it "knows that l1 intersects c1 twice" do
        intersection_point_1 = Point.new(91.963262, 100)
        intersection_point_2 = Point.new(10.007413, 100)

        actual = IntersectionChecker.check(l1, c1)

        expect(actual.length).to eq(2)
        expect(actual.first).to approximate(intersection_point_1).within(0.000001)
        expect(actual.last).to approximate(intersection_point_2).within(0.000001)
      end
    end
  end
end
