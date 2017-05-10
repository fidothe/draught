require 'draught/path_builder'
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

      it "can output a Path representing itself" do
        expect(subject.path).to eq(Path.new([Point::ZERO, finish]))
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
      specify "a line of width N is a Path with points at (0,0) and (N,0)" do
        expected = PathBuilder.build { |p| p << Point::ZERO << Point.new(10, 0) }

        expect(Line.horizontal(10)).to eq(expected)
      end
    end

    describe "generating vertical lines" do
      specify "a line of height N is a Path with points at (0,0) and (0,N)" do
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
  end
end
