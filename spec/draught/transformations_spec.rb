require 'draught/transformations'
require 'draught/point'

module Draught
  RSpec.describe Transformations do
    describe "units" do
      it "can convert mm to Postscript pts" do
        expect(Point.new(1,1).transform(Transformations.mm_to_pt)).
          to eq(Point.new(2.8346456692913, 2.8346456692913))
      end
    end

    describe "Affine" do
      it "can reflect around the x axis" do
        expect(Point.new(1,1).transform(Transformations.x_axis_reflect)).
          to eq(Point.new(1, -1))
      end

      it "can reflect around the y axis" do
        expect(Point.new(1,1).transform(Transformations.y_axis_reflect)).
          to eq(Point.new(-1, 1))
      end

      it "can reflect around the x and y axis" do
        expect(Point.new(1,1).transform(Transformations.xy_axis_reflect)).
          to eq(Point.new(-1, -1))
      end
    end

    describe "housekeeping" do
      it "can round off to a number of decimal places" do
        expect(Point.new(2.8346556692913, 2.8346556692913).transform(Transformations.round_to_n_decimal_places(4))).
          to eq(Point.new(2.8347, 2.8347))
      end
    end
  end
end
