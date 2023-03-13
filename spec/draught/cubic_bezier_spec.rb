require 'draught/world'
require 'draught/cubic_bezier'
require 'draught/pointlike_examples'

module Draught
  RSpec.describe CubicBezier do
    let(:world) { World.new }
    let(:end_point) { world.point.new(4,0) }
    let(:control_1) { world.point.new(1,2) }
    let(:control_2) { world.point.new(3,2) }
    let(:curve_opts) {
      {end_point: end_point, control_point_1: control_1, control_point_2: control_2}
    }

    subject { CubicBezier.new(world, curve_opts) }

    it_behaves_like "a point-like thing"

    specify "returns its end_point for #position_point" do
      expect(subject.position_point).to be(subject.end_point)
    end

    it "has an end point" do
      expect(subject.end_point).to eq(end_point)
    end

    it "has a first control point" do
      expect(subject.control_point_1).to eq(control_1)
    end

    it "has a second control point" do
      expect(subject.control_point_2).to eq(control_2)
    end

    describe "comparisons" do
      context "equality" do
        let(:curve_1) { CubicBezier.new(world, curve_opts) }
        let(:curve_2) { CubicBezier.new(world, curve_opts) }

        specify "a curve is equal to another if they have the same end and control points" do
          expect(curve_1 == curve_2).to be(true)
        end

        specify "a curve is not equal to another if their endpoints differ" do
          curve = CubicBezier.new(world, curve_opts.merge(end_point: control_2))
          expect(curve_1 == curve).to be(false)
        end

        specify "a curve is not equal to another if their control point are reversed" do
          curve = CubicBezier.new(world, curve_opts.merge({
            control_point_1: control_2, control_point_2: control_1
          }))
          expect(curve_1 == curve).to be(false)
        end

        specify "a CubicBezier is not equal to a Point, even if they share the same x,y" do
          expect(curve_1 == curve_1.end_point).to be(false)
        end
      end

      context "approximation" do
        specify "a CubicBezier approximates another points if their co-ordinates are within the specified delta" do
          nudge = world.vector.new(0.000001, 0.000001)
          approx_curve_opts = Hash[curve_opts.map { |opt, point| [opt, point.translate(nudge)] }]
          approx_curve = CubicBezier.new(world, approx_curve_opts)
          expect(subject.approximates?(approx_curve, 0.00001)).to be(true)
        end
      end
    end

    describe "manipulations in space" do
      let(:curve_opts) {
        {end_point: world.point.new(4,0), control_point_1: world.point.new(1,2), control_point_2: world.point.new(3,2)}
      }
      specify "a bezier can be translated using a vector to produce a new bezier" do
        translation = world.vector.new(1,2)
        expected = CubicBezier.new(world, {
          end_point: world.point.new(5,2), control_point_1: world.point.new(2,4),
          control_point_2: world.point.new(4,4)
        })

        expect(subject.translate(translation)).to eq(expected)
      end

      specify "a bezier can be transformed by a lambda-like object which takes every point (end and control) and returns new ones used to make a new curve" do
        transformer = ->(point, world) {
          world.point.new(point.x + 1, point.y + 1)
        }
        expected = CubicBezier.new(world, {
          end_point: world.point.new(5,1), control_point_1: world.point.new(2,3),
          control_point_2: world.point.new(4,3)
        })

        expect(subject.transform(transformer)).to eq(expected)
      end
    end

    describe "pretty printing" do
      specify "a cubic bezier generates a PS-like 'C c1 c2 p1' string" do
        expect(subject).to pp_as("C 1,2 3,2 4,0\n")
      end
    end
  end
end
