require 'draught/world'
require 'draught/curve_segment'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'

module Draught
  RSpec.describe CurveSegment do
    let(:world) { World.new }
    let(:start_point) { world.point.zero }
    let(:end_point) { world.point.new(4,0) }
    let(:control_point_1) { world.point.new(1,2) }
    let(:control_point_2) { world.point.new(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic) { CubicBezier.new(world, cubic_opts) }
    let(:segment_opts) { {start_point: start_point, cubic_bezier: cubic} }

    subject { CurveSegment.build(world, segment_opts) }

    describe "[] access" do
      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(world.path.new([world.point.zero]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[1,1]).to eq(world.path.new([cubic]))
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:points) { [start_point, cubic] }
      subject { CurveSegment.build(world, segment_opts) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { CurveSegment.build(world, segment_opts) }
    end

    it "knows it's not a line" do
      expect(subject.line?).to be(false)
    end

    it "knows it's a curve" do
      expect(subject.curve?).to be(true)
    end

    describe "building a Curve Segment from a hash" do
      it "can be handed a start_point and cubic_bezier" do
        expect(CurveSegment.build(world, {
          start_point: start_point, cubic_bezier: cubic
        })).to eq(subject)
      end

      it "can be handed start, end and cubic control points" do
        expect(CurveSegment.build(world, {
          start_point: start_point, end_point: end_point,
          control_point_1: control_point_1,
          control_point_2: control_point_2
        })).to eq(subject)
      end
    end

    context "building a Curve Segment from a two-item Path" do
      it "generates the CurveSegment correctly" do
        path = world.path.new([start_point, cubic])

        expect(CurveSegment.from_path(world, path)).to eq(path)
      end

      it "blows up for a > 2-item Path" do
        path = world.path.new([start_point, cubic, world.point.new(6,6)])

        expect {
          CurveSegment.from_path(world, path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a < 2-item Path" do
        path = world.path.new([world.point.zero])

        expect {
          CurveSegment.from_path(world, path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the first item isn't a Point" do
        path = world.path.new([cubic, start_point])

        expect {
          CurveSegment.from_path(world, path)
        }.to raise_error(ArgumentError)
      end

      it "blows up if the last item isn't a CubicBezier" do
        path = world.path.new([start_point, end_point])

        expect {
          CurveSegment.from_path(world, path)
        }.to raise_error(ArgumentError)
      end
    end

    describe "calculating the bounding box of the segment" do
      let(:start_point) { world.point.new(120,160) }
      let(:end_point) { world.point.new(220,40) }
      let(:control_point_1) { world.point.new(35,220) }
      let(:control_point_2) { world.point.new(220,260) }

      it "has the correct lower-left point" do
        expect(subject.lower_left).to approximate(world.point.new(97.6645,40)).within(4)
      end

      it "has the correct upper-right point" do
        expect(subject.upper_right).to approximate(world.point.new(220,207.2395)).within(4)
      end

      it "has the correct width" do
        expect(subject.width).to be_within(0.0001).of(122.3355)
      end

      it "has the correct height" do
        expect(subject.height).to be_within(0.0001).of(167.2395)
      end

      context "for a curve where derivative-of-the-curve fails" do
        let(:start_point) { world.point.new(0,0) }
        let(:end_point) { world.point.new(1000,0) }
        let(:control_point_1) { world.point.new(100,1000) }
        let(:control_point_2) { world.point.new(900,1000) }

        it "has the correct lower-left point" do
          expect(subject.lower_left).to approximate(world.point.new(0, 0)).within(4)
        end

        it "has the correct upper-right point" do
          expect(subject.upper_right).to approximate(world.point.new(1000,750)).within(4)
        end

        it "has the correct width" do
          expect(subject.width).to be_within(0.0001).of(1000)
        end

        it "has the correct height" do
          expect(subject.height).to be_within(0.0001).of(750)
        end
      end
    end

    describe "pretty printing" do
      specify "a generates its pathlike start-point plus cubic string" do
        expect(subject).to pp_as("(Pc 0,0 C 1,2 3,2 4,0)\n")
      end
    end
  end
end
