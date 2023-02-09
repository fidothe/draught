require_relative './intersection_checker/line'
require_relative './intersection_checker/curve_line'
require_relative './intersection_checker/iterative_intersection_finder'
require_relative './tolerance'

module Draught
  class IntersectionChecker
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def check(segment_1, segment_2)
      if segment_1.line? && segment_2.line?
        Line.check(world, segment_1, segment_2)
      elsif segment_1.curve? && segment_2.curve?
        IterativeIntersectionFinder.check(world, segment_1, segment_2)
      else
        CurveLine.check(world, segment_1, segment_2)
      end
    end
  end
end
