require 'draught/intersection_finder/segment'
require 'draught/world'
require 'draught/segment/line'
require 'draught/segment/curve'
require 'intersection_helper'

module Draught
  RSpec.describe IntersectionFinder::Segment do
    include IntersectionHelper::Matchers

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
        expect(subject.find(l1, l2)).to eq([world.point.new(2,2)])
      end

      it "knows that l1 and l3 don't insersect" do
        expect(subject.find(l1, l3)).to eq([])
      end

      it "knows that l1 and l4 don't intersect" do
        expect(subject.find(l1, l4)).to eq([])
      end

      context "tolerances" do
        it "knows that l1 and l5 should intersect at the default tolerance, despite the tiny discrepancy" do
          expect(subject.find(l1, l5)).to eq([wonky_point])
        end

        it "knows that l1 and l5 should not intersect at a finer tolerance" do
          tolerance = Tolerance.with_delta(0.000_000_000_1)
          world = World.new(tolerance)
          expect(described_class.new(world).find(l1, l5)).to eq([])
        end
      end

      context "An intersection check that was failing in the wild" do
        let(:l1) { world.line_segment.build(start_point: world.point.new(8.8134765625,96.97265625), end_point: world.point.new(16.6015625,116.015625)) }
        let(:l2) { world.line_segment.build(start_point: world.point.new(6.25,100.0), end_point: world.point.new(12.5,100.0)) }

        specify "should report a sane intersection" do
          expect(subject.find(l1, l2)).to eq([world.point.new(10.05158253,100)])
        end
      end
    end

    describe "curves" do
      # Affinity Designer mostly rounds to 3 d.p. in its SVG output, but rounds
      # to 1 d.p. in the UI. In my experience 1 d.p. is closer to the mark than
      # 3 d.p. when comparing Draught intersections with Affinity Designer
      # intersections. I'm now using a tolerance of 0.1 and adding zeroes above
      # the decimal using (10000,10000) instead of the original (100,100).
      let(:tolerance) { Tolerance.new(0.1) }
      let(:world) { World.new(tolerance) }

      describe "curve/line intersections" do
        specify "2 intersections, with an analytic solution" do
          is_expected.to find_intersections_of('line', 'curve').in('intersection/curve-line/2-intersection.svg')
        end

        specify "2 intersections, with no analytic solution" do
          is_expected.to find_intersections_of('line', 'curve').in('intersection/curve-line/2-intersection-no-analytic.svg')
        end

        specify "3 intersections" do
          is_expected.to find_intersections_of('line', 'curve').in('intersection/curve-line/3-intersection.svg')
        end
      end

      describe "curve/curve intersections" do
        specify "2 intersections" do
          is_expected.to find_intersections_of('curve-1', 'curve-2').in('intersection/curve-curve/2-intersection.svg')
        end

        specify "6 intersections" do
          is_expected.to find_intersections_of('curve-1', 'curve-2').in('intersection/curve-curve/6-intersection.svg').debug
        end
      end
    end
  end
end
