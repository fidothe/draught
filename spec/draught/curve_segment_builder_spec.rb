require 'draught/curve_segment_builder'
require 'draught/world'

module Draught
  RSpec.describe CurveSegmentBuilder do
    let(:world) { World.new }
    subject { described_class.new(world) }

    let(:world) { World.new }
    let(:start_point) { world.point.zero }
    let(:end_point) { world.point.new(4,0) }
    let(:control_point_1) { world.point.new(1,2) }
    let(:control_point_2) { world.point.new(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic_bezier) { CubicBezier.new(world, cubic_opts) }
    let(:expected_curve_segment) {
      CurveSegment.new(world, start_point: start_point, cubic_bezier: cubic_bezier)
    }

    describe "building a Curve Segment from a hash" do
      it "can be handed a start_point and cubic_bezier" do
        expect(subject.build({
          start_point: start_point, cubic_bezier: cubic_bezier
        })).to eq(expected_curve_segment)
      end

      it "can be handed start, end and cubic control points" do
        expect(subject.build({
          start_point: start_point, end_point: end_point,
          control_point_1: control_point_1,
          control_point_2: control_point_2
        })).to eq(expected_curve_segment)
      end
    end

    context "building a Curve Segment from a two-item Path" do
      it "generates the CurveSegment correctly" do
        path = world.path.new(points: [start_point, cubic_bezier])

        expect(subject.from_path(path)).to eq(expected_curve_segment)
      end

      it "blows up for a > 2-item Path" do
        path = world.path.new(points: [start_point, cubic_bezier, world.point.new(6,6)])

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a < 2-item Path" do
        path = world.path.new(points: [world.point.zero])

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the first item isn't a Point" do
        path = world.path.new(points: [cubic_bezier, start_point])

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the last item isn't a CubicBezier" do
        path = world.path.new(points: [start_point, end_point])

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
