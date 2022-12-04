require 'draught/arc'
require 'draught/world'

module Draught
  RSpec.describe Arc do
    let(:world) { World.new }
    let(:degrees) { 90 }
    let(:radians) { deg_to_rad(degrees) }
    subject { Arc.new(world, radius: 100, radians: radians) }

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
      let(:first_90) {
        CubicBezier.new(world, {
          end_point: world.point.new(-100, 100), control_point_1: world.point.new(0, 55.22847),
          control_point_2: world.point.new(-44.77153, 100)
        })
      }
      let(:second_90) {
        CubicBezier.new(world, {
          end_point: world.point.new(-200, 0), control_point_1: world.point.new(-155.22847, 100),
          control_point_2: world.point.new(-200, 55.22847)
        })
      }
      let(:third_90) {
        CubicBezier.new(world, {
          end_point: world.point.new(-100, -100), control_point_1: world.point.new(-200, -55.22847),
          control_point_2: world.point.new(-155.22847, -100)
        })
      }
      let(:fourth_90) {
        CubicBezier.new(world, {
          end_point: world.point.zero, control_point_1: world.point.new(-44.77153, -100),
          control_point_2: world.point.new(0, -55.22847)
        })
      }

      context "generating a one-segment curve for a 90º arc" do
        let(:expected) { Path.new(world, [
          world.point.zero,
          Curve.new(world, end_point: world.point.new(-100,100), cubic_beziers: [first_90])
        ]) }

        it "creates the expected curve" do
          expect(subject.path).to approximate(expected).within(0.00001)
        end

        it "doesn't create a two segment-curve when the arc is a floating-point precision-wobble greater than 90º" do
          a_hair_greater_than_90_degrees = Math::PI/1.999999999999999
          builder = described_class.new(world, radius: 100, radians: a_hair_greater_than_90_degrees)

          expect(builder.path).to approximate(expected).within(0.00001)
        end
      end

      it "generates a two-segment curve for a 180º arc" do
        path = Path.new(world, [
          world.point.zero,
          Curve.new(world, end_point: world.point.new(-200,0), cubic_beziers: [first_90, second_90])
        ])
        pp path
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(180))

        expect(builder.path).to approximate(path).within(0.00001)
      end

      it "generates a three-segment curve for a 270º arc" do
        path = Path.new(world, [
          world.point.zero,
          Curve.new(world, end_point: world.point.new(-100,-100), cubic_beziers: [first_90, second_90, third_90])
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(270))

        expect(builder.path).to approximate(path).within(0.00001)
      end

      it "generates a four-segment curve for a 360º arc" do
        path = Path.new(world, [
          world.point.zero,
          Curve.new(world, end_point: world.point.zero, cubic_beziers: [first_90, second_90, third_90, fourth_90])
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(360))

        expect(builder.path).to approximate(path).within(0.00001)
      end

      it "generates a two-segment curve for an arc between 90 and 180º" do
        path = Path.new(world, [
          world.point.zero,
          Curve.new(world, {
            end_point: world.point.new(-117.36482, 98.48078),
            cubic_beziers: [
              first_90,
              CubicBezier.new(world, {
                end_point: world.point.new(-117.36482, 98.48078),
                control_point_1: world.point.new( -105.82146, 100),
                control_point_2: world.point.new(-111.63179, 99.49166)
              })
            ]
          })
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(100))

        expect(builder.path).to approximate(path).within(0.00001)
      end

      context "negative angles" do
        it "generates a clockwise arc if a negative angle is used" do
          cubic_beziers = [
            CubicBezier.new(world, {
              end_point: world.point.new(-100, -100), control_point_1: world.point.new(0, -55.22847),
              control_point_2: world.point.new(-44.77153, -100)
            }),
            CubicBezier.new(world, {
              end_point: world.point.new(-200, 0), control_point_1: world.point.new(-155.22847, -100),
              control_point_2: world.point.new(-200, -55.22847)
            }),
            CubicBezier.new(world, {
              end_point: world.point.new(-100, 100), control_point_1: world.point.new(-200, 55.22847),
              control_point_2: world.point.new(-155.22847, 100)
            }),
            CubicBezier.new(world, {
              end_point: world.point.new(0, 0), control_point_1: world.point.new(-44.77153, 100),
              control_point_2: world.point.new(0, 55.22847)
            })
          ]
          path = Path.new(world, [
            world.point.zero,
            Curve.new(world, end_point: world.point.zero, cubic_beziers: cubic_beziers)
          ])
          builder = described_class.new(world, radius: 100, radians: deg_to_rad(-360))

          expect(builder.path).to approximate(path).within(0.00001)
        end

        it "generates correct clockwise arcs when the angle is not a clean right-angle" do
          path = Path.new(world, [
            world.point.zero,
            Curve.new(world, {
              end_point: world.point.new(-117.36482, -98.48078),
              cubic_beziers: [
                CubicBezier.new(world, {
                  end_point: world.point.new(-100, -100), control_point_1: world.point.new(0, -55.22847),
                  control_point_2: world.point.new(-44.77153, -100)
                }),
                CubicBezier.new(world, {
                  end_point: world.point.new(-117.36482, -98.48078),
                  control_point_1: world.point.new( -105.82146, -100),
                  control_point_2: world.point.new(-111.63179, -99.49166)
                })
              ]
            })
          ])
          builder = described_class.new(world, radius: 100, radians: deg_to_rad(-100))

          expect(builder.path).to approximate(path).within(0.00001)
        end
      end

      it "always generates paths whose first point is at 0,0 even with a non-zero starting angle" do
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(90), starting_angle: deg_to_rad(15))

        expect(builder.path.first).to eq(world.point.zero)
      end
    end
  end
end
