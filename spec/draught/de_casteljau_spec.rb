require 'draught/world'
require 'draught/segment/curve'
require 'draught/de_casteljau'

module Draught
  RSpec.describe DeCasteljau do
    let(:world) { World.new }
    let(:start_point) { world.point.zero }
    let(:end_point) { world.point.new(4,0) }
    let(:control_point_1) { world.point.new(1,2) }
    let(:control_point_2) { world.point.new(3,2) }
    let(:cubic_opts) { {
      end_point: end_point, control_point_1: control_point_1,
      control_point_2: control_point_2
    } }
    let(:cubic) { CubicBezier.new(world, cubic_opts) }
    let(:segment_opts) { {start_point: start_point, cubic_bezier: cubic} }

    let(:curve_segment) { world.curve_segment.build(segment_opts) }

    describe "splitting the curve at t = 0.5" do
      let(:mid_point) { world.point.new(2, 1.5) }
      let(:left_cp_1) { world.point.new(0.5, 1) }
      let(:left_cp_2) { world.point.new(1.25, 1.5) }
      let(:right_cp_1) { world.point.new(2.75, 1.5) }
      let(:right_cp_2) { world.point.new(3.5, 1) }

      let(:left_split_segment) {
        world.curve_segment.build(
          start_point: start_point, end_point: mid_point, control_point_1: left_cp_1, control_point_2: left_cp_2
        )
      }
      let(:right_split_segment) {
        world.curve_segment.build(
          start_point: mid_point, end_point: end_point, control_point_1: right_cp_1, control_point_2: right_cp_2
        )
      }

      specify "generates the expected left-hand curve segment from the split" do
        expect(DeCasteljau.split(world, curve_segment, 0.5).first).to eq(left_split_segment)
      end

      specify "generates the expected right-hand curve segment from the split" do
        expect(DeCasteljau.split(world, curve_segment, 0.5).last).to eq(right_split_segment)
      end
    end

    describe "splitting the curve at t = 0.2" do
      let(:left_cp_1) { world.point.new(0.2, 0.4) }
      let(:left_cp_2) { world.point.new(0.44, 0.7200000000000001) }
      let(:mid_point) { world.point.new(0.704, 0.9600000000000001) }
      let(:right_cp_1) { world.point.new(1.76, 1.92) }
      let(:right_cp_2) { world.point.new(3.2, 1.6) }

      let(:left_split_segment) {
        world.curve_segment.build(
          start_point: start_point, end_point: mid_point, control_point_1: left_cp_1, control_point_2: left_cp_2
        )
      }
      let(:right_split_segment) {
        world.curve_segment.build(
          start_point: mid_point, end_point: end_point, control_point_1: right_cp_1, control_point_2: right_cp_2
        )
      }

      specify "generates the expected left-hand curve segment from the split" do
        expect(DeCasteljau.split(world, curve_segment, 0.2).first).to eq(left_split_segment)
      end

      specify "generates the expected right-hand curve segment from the split" do
        expect(DeCasteljau.split(world, curve_segment, 0.2).last).to eq(right_split_segment)
      end
    end
  end
end
