require 'draught/world'
require 'draught/segment/curve'
require 'draught/extent_examples'
require 'draught/pathlike_examples'
require 'draught/segmentlike_examples'
require 'draught/boxlike_examples'
require 'svg_fixture_helper'

module Draught::Segment
  RSpec.describe Curve do
    let(:world) { Draught::World.new }
    let(:metadata) { Draught::Metadata::Instance.new(name: 'name') }
    let(:start_point) { world.point.zero }
    let(:end_point) { world.point(4,0) }
    let(:control_point_1) { world.point(1,2) }
    let(:control_point_2) { world.point(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic) { Draught::CubicBezier.new(world, **cubic_opts) }
    let(:segment_opts) { {start_point: start_point, cubic_bezier: cubic} }

    subject { Curve.build(world, **segment_opts) }

    context "metadata" do
      it "can be initialized with a Metadata" do
        path = described_class.new(world, metadata: metadata, **segment_opts)

        expect(path.metadata).to be(metadata)
      end

      specify "has a blank Metadata by default" do
        expect(subject.metadata).to be(Draught::Metadata::BLANK)
      end
    end

    describe "[] access" do
      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(world.path.new(points: [subject.first]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[0,1]).to eq(world.path.new(points: [subject.first]))
      end
    end

    specify "can return a Path copy of itself" do
      expect(subject.to_path).to eq(world.path.simple(*subject.points))
    end

    it_should_behave_like "a pathlike thing" do
      subject { described_class.build(world, **segment_opts) }
      let(:points) { subject.points }
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.build(world, **segment_opts) }
      let(:lower_left) { world.point.zero }
      let(:upper_right) { world.point(4,1.5) }
    end

    it_should_behave_like "a segmentlike thing" do
      subject { described_class.build(world, **segment_opts) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { described_class.build(world, **segment_opts) }
    end

    it "knows it's not a line" do
      expect(subject.line?).to be(false)
    end

    it "knows it's a curve" do
      expect(subject.curve?).to be(true)
    end

    describe "building a Curve Segment" do
      it "can be handed a start_point and cubic_bezier" do
        expect(Curve.build(world,
          start_point: start_point, cubic_bezier: cubic
        )).to eq(subject)
      end

      it "can be handed start, end and cubic control points" do
        expect(Curve.build(world,
          start_point: start_point, end_point: end_point,
          control_point_1: control_point_1,
          control_point_2: control_point_2
        )).to eq(subject)
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

    describe "projecting points onto the curve", :svg_fixture do
      svg_fixture('curves/point-projection.svg') {
        fetch_all(name: /^[a-z0-9_-]+$/)
        map_paths { |world, path| world.curve_segment.from_path(path) }
      }.each do |world, curve, name|
        specify "correctly projects points from the curve #{name} back onto itself" do
          100.times do
            t = Kernel.rand
            point = curve.compute_point(t)
            expect(curve.project_point(point)).to be_within(0.0001).of(t)
          end
        end
      end
    end

    describe "splitting a curve" do
      specify "uses DeCasteljau under the hood" do
        expect(subject.split(0.5)).to eq(Draught::DeCasteljau.split(world, subject, 0.5))
      end
    end

    specify "can convert itself into a line" do
      expect(subject.line).to eq(world.line_segment.build(start_point: subject.start_point, end_point: subject.end_point))
    end

    describe "pretty printing" do
      specify "a generates its pathlike start-point plus cubic string" do
        expect(subject).to pp_as("(Pc 0,0 C 1,2 3,2 4,0)\n")
      end
    end
  end
end
