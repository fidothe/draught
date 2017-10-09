require_relative './intersection_checker/line'
require_relative './intersection_checker/curve_line'

module Draught
  module IntersectionChecker
    def self.check(segment_1, segment_2)
      if segment_1.line? && segment_2.line?
        Line.check(segment_1, segment_2)
      else
        CurveLine.check(segment_1, segment_2)
      end
    end
  end
end
