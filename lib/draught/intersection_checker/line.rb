require_relative '../point'

module Draught
  module IntersectionChecker
    # Calculates intersection point of two line segments, if there is one.
    # Based on https://pomax.github.io/bezierinfo/#line-line-intersections
    # and https://www.topcoder.com/community/data-science/data-science-tutorials/geometry-concepts-line-intersection-and-its-applications/#line_line_intersection
    # @api private
    class Line
      def self.check(segment_1, segment_2)
        new(segment_1, segment_2).check
      end

      attr_reader :segment_1, :segment_2

      def initialize(segment_1, segment_2)
        @segment_1, @segment_2 = segment_1, segment_2
      end

      def check
        return [] if segments_parallel?
        return [] unless point_on_both_segments?
        [intersection_point]
      end

      private

      def point_on_both_segments?
        point_on_segment?(segment_1) && point_on_segment?(segment_2)
      end

      def point_on_segment?(segment)
        xs = segment.points.map(&:x)
        ys = segment.points.map(&:y)
        (xs.min..xs.max).include?(intersection_point.x) && (ys.min..ys.max).include?(intersection_point.y)
      end

      def segments_parallel?
        d == 0
      end

      def intersection_point
        @intersection_point ||= begin
          nx = ((x1 * y2) - (y1 * x2) * (x3 - x4)) - ((x1 - x2) * ((x3 * y4) - (y3 * x4)))
          ny = ((x1 * y2) - (y1 * x2) * (y3 - y4)) - ((y1 - y2) * ((x3 * y4) - (y3 * x4)))
          Draught::Point.new(nx/d, ny/d)
        end
      end

      def d
        @d ||= ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4)).to_f
      end

      def x1
        @x1 ||= segment_1.start_point.x
      end

      def x2
        @x2 ||= segment_1.end_point.x
      end

      def x3
        @x3 ||= segment_2.start_point.x
      end

      def x4
        @x4 ||= segment_2.end_point.x
      end

      def y1
        @y1 ||= segment_1.start_point.y
      end

      def y2
        @y2 ||= segment_1.end_point.y
      end

      def y3
        @y3 ||= segment_2.start_point.y
      end

      def y4
        @y4 ||= segment_2.end_point.y
      end
    end
  end
end
