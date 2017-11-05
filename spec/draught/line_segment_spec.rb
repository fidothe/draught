require 'draught/path_builder'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'
require 'draught/line_segment'

module Draught
  RSpec.describe LineSegment do
    def deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    describe "building a LineSegment between two Points" do
      let(:finish) { Point.new(4,4) }
      subject { LineSegment.build(end_point: finish) }

      it "knows how long it is" do
        expect(subject.length).to be_within(0.01).of(5.66)
      end

      it "knows what angle (in radians) it's at" do
        expect(subject.radians).to be_within(0.0001).of(deg_to_rad(45))
      end

      it "knows it's a line" do
        expect(subject.line?).to be(true)
      end

      it "knows it's not a curve" do
        expect(subject.curve?).to be(false)
      end

      specify "a line_segment at 0º should have radians == 0" do
        line_segment = LineSegment.build(end_point: Point.new(10,0))

        expect(line_segment.radians).to be_within(0.0001).of(0)
      end

      context "angles >= 90º" do
        it "copes with a line_segment of angle 90º" do
          line_segment = LineSegment.build(end_point: Point.new(0,4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(90))
        end

        it "copes with a line_segment of angle < 180º" do
          line_segment = LineSegment.build(end_point: Point.new(-4,4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(135))
        end

        it "copes with a line_segment of angle 180º" do
          line_segment = LineSegment.build(end_point: Point.new(-4,0))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(180))
        end

        it "copes with a line_segment of angle < 270º" do
          line_segment = LineSegment.build(end_point: Point.new(-4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(225))
        end

        it "copes with a line_segment of angle 270º" do
          line_segment = LineSegment.build(end_point: Point.new(0,-4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(270))
        end

        it "copes with a line_segment of angle < 360º" do
          line_segment = LineSegment.build(end_point: Point.new(4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(315))
        end
      end
    end

    describe "generating horizontal line_segments" do
      specify "a line_segment of width N is like a Path with points at (0,0) and (N,0)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(10, 0) }

        expect(LineSegment.horizontal(10)).to eq(expected)
      end
    end

    describe "generating vertical line_segments" do
      specify "a line_segment of height N is like a Path with points at (0,0) and (0,N)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(0, 10) }

        expect(LineSegment.vertical(10)).to eq(expected)
      end
    end

    describe "generating line_segments of a given length and angle" do
      let(:length) { 5.656854 }

      it "copes with a line_segment of angle 0º" do
        expected = LineSegment.build(end_point: Point.new(length,0))

        expect(LineSegment.build(length: length, radians: 0)).to eq(expected)
      end

      it "copes with a line_segment of angle 45º" do
        expected = LineSegment.build(end_point: Point.new(4,4))

        expect(LineSegment.build({
          length: length, radians: deg_to_rad(45)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line_segment of angle 90º" do
        expected = LineSegment.build(end_point: Point.new(0,length))

        expect(LineSegment.build(length: length, radians: deg_to_rad(90))).to eq(expected)
      end

      it "copes with a line_segment of angle < 180º" do
        expected = LineSegment.build(end_point: Point.new(-4,4))

        expect(LineSegment.build({
          length: length, radians: deg_to_rad(135)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line_segment of angle 180º" do
        expected = LineSegment.build(end_point: Point.new(-length,0))

        expect(LineSegment.build(length: length, radians: deg_to_rad(180))).to eq(expected)
      end

      it "copes with a line_segment of angle < 270º" do
        expected = LineSegment.build(end_point: Point.new(-4,-4))

        expect(LineSegment.build({
          length: length, radians: deg_to_rad(225)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line_segment of angle 270º" do
        expected = LineSegment.build(end_point: Point.new(0,-length))

        expect(LineSegment.build({
          length: length, radians: deg_to_rad(270)
        })).to eq(expected)
      end

      it "copes with a line_segment of angle < 360º" do
        expected = LineSegment.build(end_point: Point.new(4,-4))

        expect(LineSegment.build({
          length: length, radians: deg_to_rad(315)
        })).to approximate(expected).within(0.00001)
      end

      context "ludicrous angles" do
        it "treats a 360º angle as 0º" do
          expected = LineSegment.build(end_point: Point.new(length,0))

          expect(LineSegment.build(length: length, radians: deg_to_rad(360))).to eq(expected)
        end

        it "treats a > 360º angle properly" do
          expected = LineSegment.build(end_point: Point.new(-4,4))

          expect(LineSegment.build({
            length: length, radians: deg_to_rad(495)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 360º right-angle properly" do
          expected = LineSegment.build(end_point: Point.new(0,length))

          expect(LineSegment.build(length: length, radians: deg_to_rad(450))).to eq(expected)
        end

        it "treats a > 720º angle properly" do
          expected = LineSegment.build(end_point: Point.new(4,-4))

          expect(LineSegment.build({
            length: length, radians: deg_to_rad(1035)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 720º right-angle properly" do
          expected = LineSegment.build(end_point: Point.new(0,-length))

          expect(LineSegment.build(length: length, radians: deg_to_rad(630))).to eq(expected)
        end
      end
    end

    describe "generating LineSegments that don't start at 0,0" do
      it "can generate a line_segment from points" do
        line_segment = LineSegment.build(start_point: Point.new(1,1), end_point: Point.new(5,5))

        expect(line_segment.radians).to be_within(0.00001).of(Math::PI/4)
        expect(line_segment.length).to be_within(0.01).of(5.66)
      end

      it "can generate a line_segment from angle/length and start point" do
        line_segment = LineSegment.build(start_point: Point.new(1,1), radians: Math::PI/4, length: 5.656854)

        expect(line_segment).to approximate(Path.new([Point.new(1,1), Point.new(5,5)])).within(0.00001)
      end
    end

    describe "manipulating line_segments" do
      let(:radians) { deg_to_rad(45) }
      let(:length) { 10 }
      subject { LineSegment.build(length: length, radians: radians) }

      context "shortening makes a new line_segment" do
        it "by moving the end point in" do
          expected = LineSegment.build(length: 8, radians: radians)

          expect(subject.extend(by: -2, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(length: 8, radians: radians)
          expected = line_segment.translate(Vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(by: -2, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      context "lengthening makes a new line_segment" do
        it "by moving the end point out" do
          expected = LineSegment.build(length: 12, radians: radians)

          expect(subject.extend(by: 2, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(length: 12, radians: radians)
          expected = line_segment.translate(Vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(by: 2, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      it "defaults to moving the end point" do
        expected = LineSegment.build(length: 12, radians: radians)

        expect(subject.extend(by: 2)).to approximate(expected).within(0.00001)
      end

      context "altering length by specifying explicitly" do
        it "by moving the end point" do
          expected = LineSegment.build(length: 20, radians: radians)

          expect(subject.extend(to: 20, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(length: 5, radians: radians)
          expected = line_segment.translate(Vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(to: 5, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      context "computing a point on the line with t (0..1, like Bezier curves)" do
        it "by moving the end point" do
          expected = LineSegment.build(length: 8, radians: radians).end_point

          expect(subject.compute_point(0.8)).to approximate(expected).within(0.00001)
        end
      end
    end

    describe "[] access" do
      subject { LineSegment.build(end_point: Point.new(2,2)) }

      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(Path.new([Point::ZERO]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[1,1]).to eq(Path.new([Point.new(2,2)]))
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:end_point) { Point.new(4,4) }
      let(:points) { [Point::ZERO, end_point] }
      subject { LineSegment.build(end_point: end_point) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { LineSegment.build(end_point: Point.new(4,4)) }
    end

    context "building a line_segment from a two-item Path" do
      it "generates the LineSegment correctly" do
        path = Path.new([Point::ZERO, Point.new(4,4)])

        expect(LineSegment.from_path(path)).to eq(path)
      end

      it "blows up for a > 2-item Path" do
        path = Path.new([Point::ZERO, Point.new(4,4), Point.new(6,6)])

        expect {
          LineSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end

      it "blows up for a < 2-item Path" do
        path = Path.new([Point::ZERO])

        expect {
          LineSegment.from_path(path)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
