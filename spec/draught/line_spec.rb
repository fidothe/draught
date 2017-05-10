require 'draught/path_builder'
require 'draught/pathlike_examples'
require 'draught/line'

module Draught
  RSpec.describe Line do
    def deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    describe "building a Line between two Points" do
      let(:finish) { Point.new(4,4) }
      subject { Line.build(end_point: finish) }

      it "knows how long it is" do
        expect(subject.length).to be_within(0.01).of(5.66)
      end

      it "knows what angle (in radians) it's at" do
        expect(subject.radians).to be_within(0.0001).of(deg_to_rad(45))
      end

      context "angles >= 90º" do
        it "copes with a line of angle 90º" do
          line = Line.build(end_point: Point.new(0,4))

          expect(line.length).to be_within(0.01).of(4)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(90))
        end

        it "copes with a line of angle < 180º" do
          line = Line.build(end_point: Point.new(-4,4))

          expect(line.length).to be_within(0.01).of(5.66)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(135))
        end

        it "copes with a line of angle 180º" do
          line = Line.build(end_point: Point.new(-4,0))

          expect(line.length).to be_within(0.01).of(4)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(180))
        end

        it "copes with a line of angle < 270º" do
          line = Line.build(end_point: Point.new(-4,-4))

          expect(line.length).to be_within(0.01).of(5.66)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(225))
        end

        it "copes with a line of angle 270º" do
          line = Line.build(end_point: Point.new(0,-4))

          expect(line.length).to be_within(0.01).of(4)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(270))
        end

        it "copes with a line of angle < 360º" do
          line = Line.build(end_point: Point.new(4,-4))

          expect(line.length).to be_within(0.01).of(5.66)
          expect(line.radians).to be_within(0.0001).of(deg_to_rad(315))
        end
      end
    end

    describe "generating horizontal lines" do
      specify "a line of width N is like a Path with points at (0,0) and (N,0)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(10, 0) }

        expect(Line.horizontal(10)).to eq(expected)
      end
    end

    describe "generating vertical lines" do
      specify "a line of height N is like a Path with points at (0,0) and (0,N)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(0, 10) }

        expect(Line.vertical(10)).to eq(expected)
      end
    end

    describe "generating lines of a given length and angle" do
      def path(end_point)
        Path.new([Point::ZERO, end_point])
      end

      let(:length) { 5.656854 }

      it "copes with a line of angle 0º" do
        line = Line.build(length: length, radians: 0)

        expect(line.path).to eq(path(Point.new(length,0)))
      end

      it "copes with a line of angle 45º" do
        line = Line.build(length: length, radians: deg_to_rad(45))

        expect(line.path).to approximate(path(Point.new(4,4))).within(0.00001)
      end

      it "copes with a line of angle 90º" do
        line = Line.build(length: length, radians: deg_to_rad(90))

        expect(line.path).to eq(path(Point.new(0,length)))
      end

      it "copes with a line of angle < 180º" do
        line = Line.build(length: length, radians: deg_to_rad(135))

        expect(line.path).to approximate(path(Point.new(-4,4))).within(0.00001)
      end

      it "copes with a line of angle 180º" do
        line = Line.build(length: length, radians: deg_to_rad(180))

        expect(line.path).to eq(path(Point.new(-length,0)))
      end

      it "copes with a line of angle < 270º" do
        line = Line.build(length: length, radians: deg_to_rad(225))

        expect(line.path).to approximate(path(Point.new(-4,-4))).within(0.00001)
      end

      it "copes with a line of angle 270º" do
        line = Line.build(length: length, radians: deg_to_rad(270))

        expect(line.path).to eq(path(Point.new(0,-length)))
      end

      it "copes with a line of angle < 360º" do
        line = Line.build(length: length, radians: deg_to_rad(315))

        expect(line.path).to approximate(path(Point.new(4,-4))).within(0.00001)
      end

      context "ludicrous angles" do
        it "treats a 360º angle as 0º" do
          line = Line.build(length: length, radians: deg_to_rad(360))

          expect(line.path).to eq(path(Point.new(length,0)))
        end

        it "treats a > 360º angle properly" do
          line = Line.build(length: length, radians: deg_to_rad(495))

          expect(line.path).to approximate(path(Point.new(-4,4))).within(0.00001)
        end

        it "treats a > 360º right-angle properly" do
          line = Line.build(length: length, radians: deg_to_rad(450))

          expect(line.path).to eq(path(Point.new(0,length)))
        end

        it "treats a > 720º angle properly" do
          line = Line.build(length: length, radians: deg_to_rad(1035))

          expect(line.path).to approximate(path(Point.new(4,-4))).within(0.00001)
        end

        it "treats a > 720º right-angle properly" do
          line = Line.build(length: length, radians: deg_to_rad(630))

          expect(line.path).to eq(path(Point.new(0,-length)))
        end
      end
    end

    describe "generating Lines that don't start at 0,0" do
      it "can generate a line from points" do
        line = Line.build(start_point: Point.new(1,1), end_point: Point.new(5,5))

        expect(line.radians).to be_within(0.00001).of(Math::PI/4)
        expect(line.length).to be_within(0.01).of(5.66)
      end

      it "can generate a line from angle/length and start point" do
        line = Line.build(start_point: Point.new(1,1), radians: Math::PI/4, length: 5.656854)

        expect(line.path).to approximate(Path.new([Point.new(1,1), Point.new(5,5)])).within(0.00001)
      end
    end

    describe "manipulating lines" do
      let(:radians) { deg_to_rad(45) }
      let(:length) { 10 }
      subject { Line.build(length: length, radians: radians) }

      context "shortening makes a new line" do
        it "by moving the end point in" do
          expected = Line.build(length: 8, radians: radians).path

          expect(subject.shorten(2).path).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_path = Line.build(length: 8, radians: radians).path
          expected = line_path.translate(Vector.translation_between(line_path.last, subject.path.last))

          expect(subject.shorten(2, :towards_end).path).to approximate(expected).within(0.00001)
        end
      end

      context "lengthening makes a new line" do
        it "by moving the end point out" do
          expected = Line.build(length: 12, radians: radians).path

          expect(subject.lengthen(2).path).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_path = Line.build(length: 12, radians: radians).path
          expected = line_path.translate(Vector.translation_between(line_path.last, subject.path.last))

          expect(subject.lengthen(2, :from_start).path).to approximate(expected).within(0.00001)
        end
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:end_point) { Point.new(4,4) }
      let(:points) { [Point::ZERO, end_point] }
      subject { Line.build(end_point: end_point) }
    end
  end
end
