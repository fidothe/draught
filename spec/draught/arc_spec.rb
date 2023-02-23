require 'draught/arc'
require 'draught/world'
require 'draught/extent_examples'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'

module Draught
  RSpec.describe Arc do
    let(:tolerance) { Tolerance.new(0.00001) }
    let(:world) { World.new(tolerance) }
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
        CubicBezier.new(world,
          end_point: world.point.new(-100, 100), control_point_1: world.point.new(0, 55.22847),
          control_point_2: world.point.new(-44.77153, 100)
        )
      }
      let(:second_90) {
        CubicBezier.new(world,
          end_point: world.point.new(-200, 0), control_point_1: world.point.new(-155.22847, 100),
          control_point_2: world.point.new(-200, 55.22847)
        )
      }
      let(:third_90) {
        CubicBezier.new(world,
          end_point: world.point.new(-100, -100), control_point_1: world.point.new(-200, -55.22847),
          control_point_2: world.point.new(-155.22847, -100)
        )
      }
      let(:fourth_90) {
        CubicBezier.new(world,
          end_point: world.point.zero, control_point_1: world.point.new(-44.77153, -100),
          control_point_2: world.point.new(0, -55.22847)
        )
      }

      context "generating a one-segment curve for a 90º arc" do
        let(:expected) { world.path.simple(points: [
          world.point.zero,
          first_90
        ]) }

        it "creates the expected curve" do
          expect(subject.path).to eq(expected)
        end

        it "doesn't create a two segment-curve when the arc is a floating-point precision-wobble greater than 90º" do
          a_hair_greater_than_90_degrees = Math::PI/1.999999999999999
          builder = described_class.new(world, radius: 100, radians: a_hair_greater_than_90_degrees)

          expect(builder.path).to eq(expected)
        end
      end

      it "generates a two-segment curve for a 180º arc" do
        path = world.path.simple(points: [
          world.point.zero,
          first_90,
          second_90
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(180))

        expect(builder.path).to eq(path)
      end

      it "generates a three-segment curve for a 270º arc" do
        path = world.path.simple(points: [
          world.point.zero,
          first_90,
          second_90,
          third_90
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(270))

        expect(builder.path).to eq(path)
      end

      it "generates a four-segment curve for a 360º arc" do
        path = world.path.simple(points: [
          world.point.zero,
          first_90,
          second_90,
          third_90,
          fourth_90
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(360))

        expect(builder.path).to eq(path)
      end

      it "generates a two-segment curve for an arc between 90 and 180º" do
        path = world.path.simple(points: [
          world.point.zero,
          first_90,
          CubicBezier.new(world,
            end_point: world.point.new(-117.36482, 98.48078),
            control_point_1: world.point.new( -105.82146, 100),
            control_point_2: world.point.new(-111.63179, 99.49166)
          )
        ])
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(100))

        expect(builder.path).to eq(path)
      end

      context "negative angles" do
        it "generates a clockwise arc if a negative angle is used" do
          cubic_beziers = [
            CubicBezier.new(world,
              end_point: world.point.new(-100, -100), control_point_1: world.point.new(0, -55.22847),
              control_point_2: world.point.new(-44.77153, -100)
            ),
            CubicBezier.new(world,
              end_point: world.point.new(-200, 0), control_point_1: world.point.new(-155.22847, -100),
              control_point_2: world.point.new(-200, -55.22847)
            ),
            CubicBezier.new(world,
              end_point: world.point.new(-100, 100), control_point_1: world.point.new(-200, 55.22847),
              control_point_2: world.point.new(-155.22847, 100)
            ),
            CubicBezier.new(world,
              end_point: world.point.new(0, 0), control_point_1: world.point.new(-44.77153, 100),
              control_point_2: world.point.new(0, 55.22847)
            )
          ]
          path = world.path.simple(points: [world.point.zero] + cubic_beziers)
          builder = described_class.new(world, radius: 100, radians: deg_to_rad(-360))

          expect(builder.path).to eq(path)
        end

        it "generates correct clockwise arcs when the angle is not a clean right-angle" do
          path = world.path.simple(points: [
            world.point.zero,
            CubicBezier.new(world,
              end_point: world.point.new(-100, -100), control_point_1: world.point.new(0, -55.22847),
              control_point_2: world.point.new(-44.77153, -100)
            ),
            CubicBezier.new(world,
              end_point: world.point.new(-117.36482, -98.48078),
              control_point_1: world.point.new( -105.82146, -100),
              control_point_2: world.point.new(-111.63179, -99.49166)
            )
          ])
          builder = described_class.new(world, radius: 100, radians: deg_to_rad(-100))

          expect(builder.path).to eq(path)
        end
      end

      it "always generates paths whose first point is at 0,0 even with a non-zero starting angle" do
        builder = described_class.new(world, radius: 100, radians: deg_to_rad(90), starting_angle: deg_to_rad(15))

        expect(builder.start_point).to eq(world.point.zero)
      end

      specify "allows a specific first (starting) point to be given" do
        p1 = world.point.new(100,100)
        arc = described_class.new(world, radius: 100, radians: deg_to_rad(90), starting_angle: deg_to_rad(15), start_point: p1)

        expect(arc.start_point).to eq(p1)
      end
    end

    it_should_behave_like "a pathlike thing" do
      subject { described_class.new(world, radius: 100, radians: deg_to_rad(90)) }
      let(:points) { subject.points }
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.new(world, radius: 100, radians: deg_to_rad(90)) }
      let(:lower_left) { world.point(-100,0) }
      let(:upper_right) { world.point(0,100) }
    end

    it_should_behave_like "a basic rectangular box-like thing"
  end
end
