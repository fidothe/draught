require 'draught/arc'

module Draught
  RSpec.describe Arc do
    def deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    let(:degrees) { 90 }
    let(:radians) { deg_to_rad(degrees) }
    subject { Arc.new(radius: 100, radians: radians) }

    it "defaults to a starting angle of 0 radians" do
      expect(subject.starting_angle).to eq(0)
    end

    it "reports its total angle in radians" do
      expect(subject.radians).to eq(radians)
    end

    it "reports its radius" do
      expect(subject.radius).to eq(100)
    end

    context "generated path" do
      it "generates a one-segment curve for a 90º arc" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(100, 55.22847),
            control_point_2: Point.new(55.22847, 100)
          })
        ])

        expect(subject.path).to approximate(path).within(0.00001)
      end

      it "generates a two-segment curve for a 180º arc" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(100, 55.22847),
            control_point_2: Point.new(55.22847, 100)
          }),
          CubicBezier.new({
            end_point: Point.new(-100, 0), control_point_1: Point.new(-55.22847, 100),
            control_point_2: Point.new(-100, 55.22847)
          })
        ])
        arc = Arc.new(radius: 100, radians: deg_to_rad(180))

        expect(arc.path).to approximate(path).within(0.00001)
      end

      it "generates a three-segment curve for a 270º arc" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(100, 55.22847),
            control_point_2: Point.new(55.22847, 100)
          }),
          CubicBezier.new({
            end_point: Point.new(-100, 0), control_point_1: Point.new(-55.22847, 100),
            control_point_2: Point.new(-100, 55.22847)
          }),
          CubicBezier.new({
            end_point: Point.new(0, -100), control_point_1: Point.new(-100, -55.22847),
            control_point_2: Point.new(-55.22847, -100)
          })
        ])
        arc = Arc.new(radius: 100, radians: deg_to_rad(270))

        expect(arc.path).to approximate(path).within(0.00001)
      end

      it "generates a four-segment curve for a 360º arc" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(100, 55.22847),
            control_point_2: Point.new(55.22847, 100)
          }),
          CubicBezier.new({
            end_point: Point.new(-100, 0), control_point_1: Point.new(-55.22847, 100),
            control_point_2: Point.new(-100, 55.22847)
          }),
          CubicBezier.new({
            end_point: Point.new(0, -100), control_point_1: Point.new(-100, -55.22847),
            control_point_2: Point.new(-55.22847, -100)
          }),
          CubicBezier.new({
            end_point: Point.new(100, 0), control_point_1: Point.new(55.22847, -100),
            control_point_2: Point.new(100, -55.22847)
          })
        ])
        arc = Arc.new(radius: 100, radians: deg_to_rad(360))

        expect(arc.path).to approximate(path).within(0.00001)
      end

      it "generates a two-segment curve for an arc between 90 and 180º" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(100, 55.22847),
            control_point_2: Point.new(55.22847, 100)
          }),
          CubicBezier.new({
            end_point: Point.new(-17.36482, 98.48078),
            control_point_1: Point.new( -5.82146, 100),
            control_point_2: Point.new(-11.63179, 99.49166)
          })
        ])
        arc = Arc.new(radius: 100, radians: deg_to_rad(100))

        expect(arc.path).to approximate(path).within(0.00001)
      end

      it "generates a clockwise arc if a negative angle is used" do
        path = Path.new([
          Point.new(100, 0),
          CubicBezier.new({
            end_point: Point.new(0, -100), control_point_1: Point.new(100, -55.22847),
            control_point_2: Point.new(55.22847, -100)
          }),
          CubicBezier.new({
            end_point: Point.new(-100, 0), control_point_1: Point.new(-55.22847, -100),
            control_point_2: Point.new(-100, -55.22847)
          }),
          CubicBezier.new({
            end_point: Point.new(0, 100), control_point_1: Point.new(-100, 55.22847),
            control_point_2: Point.new(-55.22847, 100)
          }),
          CubicBezier.new({
            end_point: Point.new(100, 0), control_point_1: Point.new(55.22847, 100),
            control_point_2: Point.new(100, 55.22847)
          })
        ])
        arc = Arc.new(radius: 100, radians: deg_to_rad(-360))

        expect(arc.path).to approximate(path).within(0.00001)
      end
    end

    context "convenience creators" do
      specify "Arc.degrees() provides a simple degrees-based angle and starting_angle creator" do
        arc = Arc.degrees(angle: 180, starting_angle: 90, radius: 1)
        expect(arc.radians).to eq(Math::PI)
        expect(arc.starting_angle).to eq(Math::PI/2)
        expect(arc.radius).to eq(1)
      end

      specify "Arc.radians() provides a radians-only constructor" do
        arc = Arc.radians(angle: Math::PI, starting_angle: Math::PI/2, radius: 1)
        expect(arc.radians).to eq(Math::PI)
        expect(arc.starting_angle).to eq(Math::PI/2)
        expect(arc.radius).to eq(1)
      end
    end

    describe "being a tiny bit pathlike" do
      subject { Arc.degrees(radius: 10, angle: 90) }

      it "returns the start point and itself when asked for #points" do
        expect(subject.points).to eq([Point.new(10, 0), subject])
      end
    end
  end
end
