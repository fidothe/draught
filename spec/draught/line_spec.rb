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
      let(:length) { 5.656854 }

      it "copes with a line of angle 0º" do
        expected = Line.build(end_point: Point.new(length,0))

        expect(Line.build(length: length, radians: 0)).to eq(expected)
      end

      it "copes with a line of angle 45º" do
        expected = Line.build(end_point: Point.new(4,4))

        expect(Line.build({
          length: length, radians: deg_to_rad(45)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line of angle 90º" do
        expected = Line.build(end_point: Point.new(0,length))

        expect(Line.build(length: length, radians: deg_to_rad(90))).to eq(expected)
      end

      it "copes with a line of angle < 180º" do
        expected = Line.build(end_point: Point.new(-4,4))

        expect(Line.build({
          length: length, radians: deg_to_rad(135)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line of angle 180º" do
        expected = Line.build(end_point: Point.new(-length,0))

        expect(Line.build(length: length, radians: deg_to_rad(180))).to eq(expected)
      end

      it "copes with a line of angle < 270º" do
        expected = Line.build(end_point: Point.new(-4,-4))

        expect(Line.build({
          length: length, radians: deg_to_rad(225)
        })).to approximate(expected).within(0.00001)
      end

      it "copes with a line of angle 270º" do
        expected = Line.build(end_point: Point.new(0,-length))

        expect(Line.build({
          length: length, radians: deg_to_rad(270)
        })).to eq(expected)
      end

      it "copes with a line of angle < 360º" do
        expected = Line.build(end_point: Point.new(4,-4))

        expect(Line.build({
          length: length, radians: deg_to_rad(315)
        })).to approximate(expected).within(0.00001)
      end

      context "ludicrous angles" do
        it "treats a 360º angle as 0º" do
          expected = Line.build(end_point: Point.new(length,0))

          expect(Line.build(length: length, radians: deg_to_rad(360))).to eq(expected)
        end

        it "treats a > 360º angle properly" do
          expected = Line.build(end_point: Point.new(-4,4))

          expect(Line.build({
            length: length, radians: deg_to_rad(495)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 360º right-angle properly" do
          expected = Line.build(end_point: Point.new(0,length))

          expect(Line.build(length: length, radians: deg_to_rad(450))).to eq(expected)
        end

        it "treats a > 720º angle properly" do
          expected = Line.build(end_point: Point.new(4,-4))

          expect(Line.build({
            length: length, radians: deg_to_rad(1035)
          })).to approximate(expected).within(0.00001)
        end

        it "treats a > 720º right-angle properly" do
          expected = Line.build(end_point: Point.new(0,-length))

          expect(Line.build(length: length, radians: deg_to_rad(630))).to eq(expected)
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

        expect(line).to approximate(Path.new([Point.new(1,1), Point.new(5,5)])).within(0.00001)
      end
    end

    describe "manipulating lines" do
      let(:radians) { deg_to_rad(45) }
      let(:length) { 10 }
      subject { Line.build(length: length, radians: radians) }

      context "shortening makes a new line" do
        it "by moving the end point in" do
          expected = Line.build(length: 8, radians: radians)

          expect(subject.shorten(2)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line = Line.build(length: 8, radians: radians)
          expected = line.translate(Vector.translation_between(line.last, subject.last))

          expect(subject.shorten(2, :towards_end)).to approximate(expected).within(0.00001)
        end
      end

      context "lengthening makes a new line" do
        it "by moving the end point out" do
          expected = Line.build(length: 12, radians: radians)

          expect(subject.lengthen(2)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line = Line.build(length: 12, radians: radians)
          expected = line.translate(Vector.translation_between(line.last, subject.last))

          expect(subject.lengthen(2, :from_start)).to approximate(expected).within(0.00001)
        end
      end
    end

    describe "[] access" do
      subject { Line.build(end_point: Point.new(2,2)) }

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
      subject { Line.build(end_point: end_point) }
    end
  end
end
