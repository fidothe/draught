require 'draught/line_segment_builder'
require 'draught/world'

module Draught
  RSpec.describe LineSegmentBuilder do
    let(:world) { World.new }
    subject { described_class.new(world) }

    let(:world) { World.new }

    describe "building a LineSegment between two Points" do
      let(:finish) { world.point.new(4,4) }
      let(:line_segment) { subject.build(end_point: finish) }

      it "knows how long it is" do
        expect(line_segment.length).to be_within(0.01).of(5.66)
      end

      it "knows what angle (in radians) it's at" do
        expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(45))
      end

      it "knows it's a line" do
        expect(line_segment.line?).to be(true)
      end

      it "knows it's not a curve" do
        expect(line_segment.curve?).to be(false)
      end

      specify "a LineSegment at 0º should have radians == 0" do
        line_segment = subject.build(end_point: world.point.new(10,0))

        expect(line_segment.radians).to be_within(0.0001).of(0)
      end

      context "angles >= 90º" do
        it "copes with a LineSegment of angle 90º" do
          line_segment = subject.build(end_point: world.point.new(0,4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(90))
        end

        it "copes with a LineSegment of angle < 180º" do
          line_segment = subject.build(end_point: world.point.new(-4,4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(135))
        end

        it "copes with a LineSegment of angle 180º" do
          line_segment = subject.build(end_point: world.point.new(-4,0))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(180))
        end

        it "copes with a LineSegment of angle < 270º" do
          line_segment = subject.build(end_point: world.point.new(-4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(225))
        end

        it "copes with a LineSegment of angle 270º" do
          line_segment = subject.build(end_point: world.point.new(0,-4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(270))
        end

        it "copes with a LineSegment of angle < 360º" do
          line_segment = subject.build(end_point: world.point.new(4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(315))
        end
      end
    end

    describe "generating horizontal LineSegment objects" do
      specify "a line_segment of width N is like a Path with points at (0,0) and (N,0)" do
        expected = world.path.build { |p| p << world.point.zero << world.point.new(10, 0) }

        expect(subject.horizontal(10)).to eq(expected)
      end
    end

    describe "generating vertical LineSegment objects" do
      specify "a line_segment of height N is like a Path with points at (0,0) and (0,N)" do
        expected = world.path.build { |p| p << world.point.zero << world.point.new(0, 10) }

        expect(subject.vertical(10)).to eq(expected)
      end
    end

    describe "generating LineSegment objects of a given length and angle" do
      let(:length) { 5.656854 }

      it "copes with a line_segment of angle 0º" do
        expected = subject.build(end_point: world.point.new(length,0))

        expect(subject.build(length: length, radians: 0)).to eq(expected)
      end

      it "copes with a LineSegment of angle 45º" do
        expected = subject.build(end_point: world.point.new(4,4))

        expect(subject.build({
          length: length, radians: deg_to_rad(45)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a LineSegment of angle 90º" do
        expected = subject.build(end_point: world.point.new(0,length))

        expect(subject.build(length: length, radians: deg_to_rad(90))).to eq(expected)
      end

      it "copes with a LineSegment of angle < 180º" do
        expected = subject.build(end_point: world.point.new(-4,4))

        expect(subject.build({
          length: length, radians: deg_to_rad(135)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a LineSegment of angle 180º" do
        expected = subject.build(end_point: world.point.new(-length,0))

        expect(subject.build(length: length, radians: deg_to_rad(180))).to eq(expected)
      end

      it "copes with a LineSegment of angle < 270º" do
        expected = subject.build(end_point: world.point.new(-4,-4))

        expect(subject.build({
          length: length, radians: deg_to_rad(225)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a LineSegment of angle 270º" do
        expected = subject.build(end_point: world.point.new(0,-length))

        expect(subject.build({
          length: length, radians: deg_to_rad(270)
        })).to eq(expected)
      end

      it "copes with a LineSegment of angle < 360º" do
        expected = subject.build(end_point: world.point.new(4,-4))

        expect(subject.build({
          length: length, radians: deg_to_rad(315)
        })).to approximate(expected).within(0.00001)
      end

      context "ludicrous angles" do
        it "treats a 360º angle as 0º" do
          expected = subject.build(end_point: world.point.new(length,0))

          expect(subject.build(length: length, radians: deg_to_rad(360))).to eq(expected)
        end

        it "treats a > 360º angle properly" do
          expected = subject.build(end_point: world.point.new(-4,4))

          expect(subject.build({
            length: length, radians: deg_to_rad(495)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 360º right-angle properly" do
          expected = subject.build(end_point: world.point.new(0,length))

          expect(subject.build(length: length, radians: deg_to_rad(450))).to eq(expected)
        end

        it "treats a > 720º angle properly" do
          expected = subject.build(end_point: world.point.new(4,-4))

          expect(subject.build({
            length: length, radians: deg_to_rad(1035)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 720º right-angle properly" do
          expected = subject.build(end_point: world.point.new(0,-length))

          expect(subject.build(length: length, radians: deg_to_rad(630))).to eq(expected)
        end
      end
    end

    describe "generating LineSegment objects that don't start at 0,0" do
      it "can generate a LineSegment from points" do
        line_segment = subject.build(start_point: world.point.new(1,1), end_point: world.point.new(5,5))

        expect(line_segment.radians).to be_within(0.00001).of(Math::PI/4)
        expect(line_segment.length).to be_within(0.01).of(5.66)
      end

      it "can generate a LineSegment from angle/length and start point" do
        line_segment = subject.build(start_point: world.point.new(1,1), radians: Math::PI/4, length: 5.656854)

        expect(line_segment).to approximate(world.path.new(points: [world.point.new(1,1), world.point.new(5,5)])).within(0.00001)
      end
    end

    describe "building a LineSegment from a two-item Path" do
      it "generates the LineSegment correctly" do
        path = world.path.new(points: [world.point.zero, world.point.new(4,4)])

        expect(subject.from_path(path)).to eq(path)
      end

      it "blows up for a > 2-item Path" do
        path = world.path.new(points: [world.point.zero, world.point.new(4,4), world.point.new(6,6)])

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
    end

    describe "building a LineSegment from two points" do
      it "generates the LineSegment correctly" do
        p1 = world.point.zero
        p2 = world.point.new(4,4)
        path = world.path.new(points: [p1, p2])

        expect(subject.from_to(p1, p2)).to eq(path)
      end
    end
  end
end
