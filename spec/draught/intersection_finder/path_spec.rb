require 'draught/intersection_finder/path'
require 'draught/world'
require 'draught/path'
require 'intersection_helper'

module Draught
  RSpec.describe IntersectionFinder::Path do
    include IntersectionHelper::Matchers

    # Affinity Designer mostly rounds to 3 d.p. in its SVG output, but rounds
    # to 1 d.p. in the UI. In my experience 1 d.p. is closer to the mark than
    # 3 d.p. when comparing Draught intersections with Affinity Designer
    # intersections. I'm now using a tolerance of 0.1 and adding zeroes above
    # the decimal using (10000,10000) instead of the original (100,100).
    let(:tolerance) { Tolerance.new(0.1) }
    let(:world) { World.new(tolerance) }
    subject { described_class.new(world) }

    # describe "marking found intersections" do
    #   let(:path_1) { world.path.simple(world.point(0,0), world.point(1,1)) }
    #   let(:path_2) { world.path.simple(world.point(0,1), world.point(1,0)) }

    #   specify "marks the intersection" do
    #   end
    # end

    describe "simple paths", :svg_fixture do
      specify "2 squares, intersecting at 2 points" do
        is_expected.to find_path_intersections_between('sq-1', 'sq-2').in('intersection/path/2-squares.svg')
      end
    end
  end
end
