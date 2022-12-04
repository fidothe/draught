require 'draught/intersection_checker'
require 'draught/world'
require 'draught/line_segment'
require 'draught/curve_segment'

module Draught
  RSpec.describe IntersectionChecker do
    let(:world) { World.new }
    subject { described_class.new(world) }

    describe "line/line intersections" do
      let(:l1) { world.line_segment.build(start_point: world.point.new(0,2), end_point: world.point.new(4,2)) }
      let(:l2) { world.line_segment.build(start_point: world.point.new(2,0), end_point: world.point.new(2,4)) }
      let(:l3) { world.line_segment.build(start_point: world.point.new(0,0), end_point: world.point.new(4,0)) }
      let(:l4) { world.line_segment.build(start_point: world.point.new(0,0), end_point: world.point.new(2,1)) }
      let(:wonky_point) { world.point.new(4.0000001, 2) }
      let(:l5) { world.line_segment.build(start_point: world.point.new(2,0), end_point: wonky_point)}

      it "knows that l1 and l2 insersect at (2,2)" do
        expect(subject.check(l1, l2)).to eq([world.point.new(2,2)])
      end

      it "knows that l1 and l3 don't insersect" do
        expect(subject.check(l1, l3)).to eq([])
      end

      it "knows that l1 and l4 don't intersect" do
        expect(subject.check(l1, l4)).to eq([])
      end

      context "tolerances" do
        it "knows that l1 and l5 should intersect at the default tolerance, despite the tiny discrepancy" do
          expect(subject.check(l1, l5)).to eq([wonky_point])
        end

        it "knows that l1 and l5 should not intersect at a finer tolerance" do
          tolerance = Tolerance.with_delta(0.000_000_000_1)
          expect(subject.check(l1, l5, tolerance)).to eq([])
        end
      end

      context "An intersection check that was failing in the wild" do
        let(:l1) { world.line_segment.build(start_point: world.point.new(8.8134765625,96.97265625), end_point: world.point.new(16.6015625,116.015625)) }
        let(:l2) { world.line_segment.build(start_point: world.point.new(6.25,100.0), end_point: world.point.new(12.5,100.0)) }

        specify "should report a sane intersection" do
          expect(subject.check(l1, l2)).to eq([world.point.new(10.05158253,100)])
        end
      end
    end

    describe "curve/line intersections" do
      let(:l1) { world.line_segment.build(start_point: world.point.new(0,100), end_point: world.point.new(100,100)) }
      let(:c1) { CurveSegment.build(world, {
        start_point: world.point.new(0,75), cubic_bezier: CubicBezier.new(world, {
          end_point: world.point.new(100,80), control_point_1: world.point.new(50,200),
          control_point_2: world.point.new(50,205)
        })
      }) }

      let(:c2) { CurveSegment.build(world, {
        start_point: world.point.new(0,75), cubic_bezier: CubicBezier.new(world, {
          end_point: world.point.new(100,75), control_point_1: world.point.new(50,200),
          control_point_2: world.point.new(50,200)
        })
      }) }

      it "knows that l1 intersects c1 twice" do
        intersection_point_1 = world.point.new(91.963262, 100)
        intersection_point_2 = world.point.new(10.007413, 100)

        actual = subject.check(l1, c1)

        expect(actual.length).to eq(2)
        expect(actual.first).to approximate(intersection_point_1).within(0.000001)
        expect(actual.last).to approximate(intersection_point_2).within(0.000001)
      end

      it "knows that l1 intersects c2 twice (analytic solutions fail)" do
        intersection_point_1 = world.point.new(10.051583, 100)
        intersection_point_2 = world.point.new(89.948417, 100)

        actual = subject.check(l1, c2)

        expect(actual.length).to eq(2)
        expect(actual.first).to approximate(intersection_point_1).within(0.000001)
        expect(actual.last).to approximate(intersection_point_2).within(0.000001)
      end
    end
  end
end
