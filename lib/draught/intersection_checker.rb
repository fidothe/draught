require_relative './intersection_checker/line'
require_relative './intersection_checker/curve_line'
require_relative './intersection_checker/curve_curve'
require_relative './tolerance'

module Draught
  class IntersectionChecker
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def check(segment_1, segment_2, tolerance = nil)
      tolerance = tolerance.nil? ? world.tolerance : tolerance
      if segment_1.line? && segment_2.line?
        Line.check(world, segment_1, segment_2, tolerance)
      elsif segment_1.curve? && segment_2.curve?
        CurveCurve.check(world, segment_1, segment_2, tolerance)
      else
        CurveLine.check(world, segment_1, segment_2, tolerance)
      end
    end
  end
end
