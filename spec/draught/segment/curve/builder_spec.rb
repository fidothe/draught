require 'draught/segment/curve/builder'
require 'draught/world'

module Draught::Segment
  RSpec.describe Curve::Builder do
    let(:world) { Draught::World.new }
    subject { described_class.new(world) }

    let(:start_point) { world.point.zero }
    let(:end_point) { world.point.new(4,0) }
    let(:control_point_1) { world.point.new(1,2) }
    let(:control_point_2) { world.point.new(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic_bezier) { world.cubic_bezier(**cubic_opts) }
    let(:expected_curve_segment) {
      Curve.new(world, start_point: start_point, cubic_bezier: cubic_bezier)
    }

    describe "building a Curve Segment from a hash" do
      it "can be handed a start_point and cubic_bezier" do
        expect(subject.build(
          start_point: start_point, cubic_bezier: cubic_bezier
        )).to eq(expected_curve_segment)
      end

      it "can be handed start, end and cubic control points" do
        expect(subject.build(
          start_point: start_point, end_point: end_point,
          control_point_1: control_point_1,
          control_point_2: control_point_2
        )).to eq(expected_curve_segment)
      end

      specify "if handed a CubicBezier as a start point, use its position point" do
        cubic_start = world.cubic_bezier(end_point: start_point, control_point_1: world.point(1,0), control_point_2: world.point(0,1))

        expect(subject.build(start_point: cubic_start, cubic_bezier: cubic_bezier)).to eq(expected_curve_segment)
      end

      context "handling Metadata" do
        let(:metadata) { Draught::Metadata::Instance.new(name: 'name') }
        let(:path) { world.path.simple(start_point, cubic_bezier, metadata: metadata) }

        context "when given a start_point and cubic_bezier" do
          let(:built_curve_segment) {
            subject.build(start_point: start_point, cubic_bezier: cubic_bezier, metadata: metadata)
          }

          specify "produces a Curve Segment with the correct Metadata" do
            expect(built_curve_segment.metadata).to be(metadata)
          end
        end

        context "when given start, end and cubic control points" do
          let(:built_curve_segment) {
            subject.build(
              start_point: start_point, end_point: end_point,
              control_point_1: control_point_1,
              control_point_2: control_point_2,
              metadata: metadata
            )
          }

          specify "produces a Curve Segment with the correct Metadata" do
            expect(built_curve_segment.metadata).to be(metadata)
          end
        end
      end
    end

    context "building a Curve Segment from a two-item Path" do
      it "generates the Curve Segment correctly" do
        path = world.path.simple(start_point, cubic_bezier)

        expect(subject.from_path(path)).to eq(expected_curve_segment)
      end

      it "blows up for a > 2-item Path" do
        path = world.path.simple(start_point, cubic_bezier, world.point.new(6,6))

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a > 2-item Path" do
        path = world.path.simple(start_point, cubic_bezier, world.point.new(6,6))

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a < 2-item Path" do
        path = world.path.simple(world.point.zero)

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the first item isn't a Point" do
        path = world.path.simple(cubic_bezier, start_point)

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the last item isn't a CubicBezier" do
        path = world.path.simple(start_point, end_point)

        expect {
          subject.from_path(path)
        }.to raise_error(ArgumentError)
      end

      specify "if handed a CubicBezier as a start point, use its position point" do
        cubic_start = world.cubic_bezier(end_point: start_point, control_point_1: world.point(1,0), control_point_2: world.point(0,1))
        path = world.path.simple(cubic_start, cubic_bezier)

        expect(subject.from_path(path)).to eq(expected_curve_segment)
      end

      context "handling Metadata" do
        let(:metadata) { Draught::Metadata::Instance.new(name: 'name') }
        let(:path) { world.path.simple(start_point, cubic_bezier, metadata: metadata) }
        let(:built_curve_segment) { subject.from_path(path) }

        specify "produces a Curve Segment with the correct Metadata" do
          expect(built_curve_segment.metadata).to be(metadata)
        end
      end

      describe "building a Curve from two points" do
        it "generates the Line correctly" do
          expect(subject.from_to(start_point, cubic_bezier)).to eq(subject.build(start_point: start_point, cubic_bezier: cubic_bezier))
        end

        specify "metadata can be passed too" do
          metadata = Draught::Metadata::Instance.new(name: 'name')
          curve_segment = subject.from_to(start_point, cubic_bezier, metadata: metadata)

          expect(curve_segment.metadata).to be(metadata)
        end

        specify "if the first point is a CubicBezier, use its position point" do
          cubic_start = world.cubic_bezier(end_point: start_point, control_point_1: world.point(1,0), control_point_2: world.point(0,1))

          expect(subject.from_to(cubic_start, cubic_bezier)).to eq(expected_curve_segment)
        end
      end
    end
  end
end
