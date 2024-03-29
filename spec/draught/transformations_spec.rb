require 'draught/transformations'
require 'draught/world'
require 'draught/point'

module Draught
  RSpec.describe Transformations do
    let(:world) { World.new }
    describe "units" do
      it "can convert mm to Postscript pts" do
        expect(world.point.new(1,1).transform(Transformations.mm_to_pt)).
          to eq(world.point.new(2.8346456692913, 2.8346456692913))
      end

      it "can convert mm to X dpi px" do
        expect(world.point.new(1,1).transform(Transformations.mm_to_dpi(300))).
          to eq(world.point.new(11.81102362, 11.81102362))
      end

      it "can convert Postscript pts to mm" do
        expect(world.point.new(2.8346456692913, 2.8346456692913).transform(Transformations.pt_to_mm)).
          to eq(world.point.new(1,1))
      end

      it "can convert X dpi px to mm" do
        expect(world.point.new(11.81102362, 11.81102362).transform(Transformations.dpi_to_mm(300))).
          to eq(world.point.new(1,1))
      end
    end

    describe "Affine" do
      it "can reflect around the x axis" do
        expect(world.point.new(1,1).transform(Transformations.x_axis_reflect)).
          to eq(world.point.new(1, -1))
      end

      it "can reflect around the y axis" do
        expect(world.point.new(1,1).transform(Transformations.y_axis_reflect)).
          to eq(world.point.new(-1, 1))
      end

      it "can reflect around the x and y axis" do
        expect(world.point.new(1,1).transform(Transformations.xy_axis_reflect)).
          to eq(world.point.new(-1, -1))
      end
    end

    describe "housekeeping" do
      it "can round off to a number of decimal places" do
        expect(world.point.new(2.8346556692913, 2.8346556692913).transform(Transformations.round_to_n_decimal_places(4))).
          to eq(world.point.new(2.8347, 2.8347))
      end
    end
  end
end
