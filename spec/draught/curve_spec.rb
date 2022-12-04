require 'draught/curve'
require 'draught/world'
require 'draught/point'
require 'draught/cubic_bezier'
require 'draught/pointlike_examples'

module Draught
  RSpec.describe Curve do
    let(:world) { World.new }
    let(:end_point) { world.point.new(12,21) }
    let(:cubic_bezier) {
      CubicBezier.new(world, {
        end_point: end_point, control_point_1: world.point.new(2,2), control_point_2: world.point.new(8,8)
      })
    }
    subject {
      Curve.new(world, end_point: end_point, cubic_beziers: [cubic_bezier])
    }

    it_behaves_like "a point-like thing"

    it "returns the x of its endpoint for #x" do
      expect(subject.x).to eq(12)
    end

    it "returns the y of its endpoint for #y" do
      expect(subject.y).to eq(21)
    end

    it "claims to a point of type curve" do
      expect(subject.point_type).to eq(:curve)
    end

    it "returns its cubic_beziers for #as_cubic_beziers" do
      expect(subject.as_cubic_beziers).to eq([cubic_bezier])
    end

    context "comparison" do
      it "doesn't compare approximately equal to a curve with more cubic segments" do
        comparison_curve = Curve.new(world, {
          end_point: end_point, cubic_beziers: [cubic_bezier, cubic_bezier]
        })
        expect(subject).not_to approximate(comparison_curve).within(1)
      end

      it "doesn't compare approximately equal to a curve with fewer cubic segments" do
        comparison_curve = Curve.new(world, {
          end_point: end_point, cubic_beziers: [cubic_bezier, cubic_bezier]
        })
        expect(comparison_curve).not_to approximate(subject).within(1)
      end
    end

    describe "manipulation in space" do
      it "translates correctly" do
        t = world.vector.new(1,2)
        expected_point = end_point.translate(t)
        expected_cubic = cubic_bezier.translate(t)

        translated = subject.translate(t)

        expect(translated.x).to eq(expected_point.x)
        expect(translated.y).to eq(expected_point.y)
        expect(translated.as_cubic_beziers).to eq([expected_cubic])
      end
    end

    describe "pretty printing" do
      specify "a curve generates its cubic string in braces when it contains one cubic" do
        expect(subject).to pp_as("{C 2,2 8,8 12,21}\n")
      end

      specify "a curve generates a PS-like space-separated sequence of cubic strings in braces when it contains multiple cubics" do
        curve = Curve.new(world, end_point: end_point, cubic_beziers: [cubic_bezier, cubic_bezier])

        expect(curve).to pp_as("{C 2,2 8,8 12,21 C 2,2 8,8 12,21}\n")
      end
    end
  end
end
