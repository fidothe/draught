require_relative '../transformations'
require_relative '../vector'
require_relative '../range_with_tolerance'
require_relative '../de_casteljau'
require_relative '../renderer/svg'

module Draught
  class IntersectionChecker
    class CurveCurve
      def self.check(world, curve_1, curve_2, tolerance)
        new(world, curve_1, curve_2, tolerance).check
      end

      attr_reader :world, :curve_1, :curve_2, :tolerance

      def initialize(world, curve_1, curve_2, tolerance)
        @world, @curve_1, @curve_2, @tolerance = world, curve_1, curve_2, tolerance
      end

      # https://jeremykun.com/2013/05/11/bezier-curves-and-picasso/
      # var curve = [[1,2], [5,5], [4,0], [9,3]];
      def curve_flat?(curve)
        flatness_tolerance = 0.01 # anything below 50 is roughly good-looking (apparently)
        ax = 3.0 * curve.control_point_1.x - 2.0 * curve.start_point.x - curve.end_point.x
        ax =  ax * ax
        ay = 3.0 * curve.control_point_1.y - 2.0 * curve.start_point.y - curve.end_point.y
        ay = ay * ay
        bx = 3.0 * curve.control_point_2.x - curve.start_point.x - 2.0 * curve.end_point.x
        bx = bx * bx
        by = 3.0 * curve.control_point_2.y - curve.start_point.y - 2.0 * curve.end_point.y
        by = by * by

        [ax, bx].max + [ay, by].max <= flatness_tolerance
      end

      def curve_as_line(curve)
        world.line_segment.build(start_point: curve.start_point, end_point: curve.end_point)
      end

      def both_curves_flat?
        curve_flat?(curve_1) && curve_flat?(curve_2)
      end

      def one_curve_flat?
        curve_flat?(curve_1) || curve_flat?(curve_2)
      end

      def flat_curve
        [curve_1, curve_2].find { |curve| curve_flat?(curve) }
      end

      def not_flat_curve
        [curve_1, curve_2].find { |curve| !curve_flat?(curve) }
      end

      def check
        if both_curves_flat?
          IntersectionChecker::Line.check(world, curve_as_line(curve_1), curve_as_line(curve_2), tolerance)
        elsif one_curve_flat? # turn the curve fragment into a line and just line-line check
          IntersectionChecker::CurveLine.check(world, not_flat_curve, curve_as_line(flat_curve), tolerance)
        else
          return [] unless curve_1.overlaps?(curve_2)
          # split curve 1 and 2
          split_curve_1 = DeCasteljau.split(world, curve_1, 0.5)
          split_curve_2 = DeCasteljau.split(world, curve_2, 0.5)
          split_curve_1.flat_map { |c1|
            split_curve_2.map { |c2|
              [c1, c2]
            }
          }.flat_map { |c1, c2|
            self.class.check(world, c1, c2, tolerance)
          }.compact
        end
      end
    end
  end
end
