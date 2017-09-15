require 'draught/curve_segment'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'

module Draught
  RSpec.describe CurveSegment do
    let(:start_point) { Point::ZERO }
    let(:end_point) { Point.new(4,0) }
    let(:control_point_1) { Point.new(1,2) }
    let(:control_point_2) { Point.new(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic) { CubicBezier.new(cubic_opts) }
    let(:segment_opts) { {start_point: start_point, cubic_bezier: cubic} }

    subject { CurveSegment.build(segment_opts) }

    describe "[] access" do
      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(Path.new([Point::ZERO]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[1,1]).to eq(Path.new([cubic]))
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:points) { [start_point, cubic] }
      subject { CurveSegment.build(segment_opts) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { CurveSegment.build(segment_opts) }
    end

    describe "building  a Curve Segment from a hash" do
      it "can be handed a start_point and cubic_bezier" do
        expect(CurveSegment.build({
          start_point: start_point, cubic_bezier: cubic
        })).to eq(subject)
      end

      it "can be handed start, end and cubic control points" do
        expect(CurveSegment.build({
          start_point: start_point, end_point: end_point,
          control_point_1: control_point_1,
          control_point_2: control_point_2
        })).to eq(subject)
      end
    end

    context "building a Curve Segment from a two-item Path" do
      it "generates the CurveSegment correctly" do
        path = Path.new([start_point, cubic])

        expect(CurveSegment.from_path(path)).to eq(path)
      end

      it "blows up for a > 2-item Path" do
        path = Path.new([start_point, cubic, Point.new(6,6)])

        expect {
          CurveSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a < 2-item Path" do
        path = Path.new([Point::ZERO])

        expect {
          CurveSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the first item isn't a Point" do
        path = Path.new([cubic, start_point])

        expect {
          CurveSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the last item isn't a CubicBezier" do
        path = Path.new([start_point, end_point])

        expect {
          CurveSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end
    end

    describe "calculating the bounding box of the segment" do
      let(:start_point) { Point.new(120,160) }
      let(:end_point) { Point.new(220,40) }
      let(:control_point_1) { Point.new(35,220) }
      let(:control_point_2) { Point.new(220,260) }

      it "has the correct lower-left point" do
        expect(subject.lower_left).to approximate(Point.new(97.6645,40)).within(4)
      end

      it "has the correct upper-right point" do
        expect(subject.upper_right).to approximate(Point.new(220,207.2395)).within(4)
      end

      it "has the correct width" do
        expect(subject.width).to be_within(0.0001).of(122.3355)
      end

      it "has the correct height" do
        expect(subject.height).to be_within(0.0001).of(167.2395)
      end
    end
  end
end
