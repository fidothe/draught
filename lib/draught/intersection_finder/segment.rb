require_relative './segment/line_line'
require_relative './segment/curve_line'
require_relative './segment/iterative'

module Draught
  module IntersectionFinder
    class Segment
      attr_reader :world

      def initialize(world)
        @world = world
      end

      def intersections(segment_1, segment_2)
        if segment_1.line? && segment_2.line?
          LineLine.intersections(world, segment_1, segment_2)
        elsif segment_1.curve? && segment_2.curve?
          Iterative.intersections(world, segment_1, segment_2)
        else
          CurveLine.intersections(world, segment_1, segment_2)
        end
      end
    end
  end
end
