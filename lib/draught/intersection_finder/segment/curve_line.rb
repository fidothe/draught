require_relative '../../transformations'
require_relative '../../vector'
require_relative '../../range_with_tolerance'
require_relative '../../renderer/svg'
require_relative 'iterative'

module Draught
  module IntersectionFinder
    class Segment
      class CurveLine
        TAU = 2 * Math::PI
        def self.find(world, segment_1, segment_2)
          curve_segment = segment_1.curve? ? segment_1 : segment_2
          line_segment = segment_1.line? ? segment_1 : segment_2

          new(world, curve_segment, line_segment).find
        end

        attr_reader :world, :curve_segment, :line_segment

        def initialize(world, curve_segment, line_segment)
          @world, @curve_segment, @line_segment = world, curve_segment, line_segment
        end

        def find
          if d_zero?
            return Iterative.find(world, curve_segment, line_segment)
          end
          curve_potential_intersection_points.select { |point|
            x_intersection_range.include?(point.x) && y_intersection_range.include?(point.y)
          }
        end

        def x_intersection_range
          RangeWithTolerance.new(line_segment.lower_left.x..line_segment.lower_right.x, world.tolerance)
        end

        def y_intersection_range
          RangeWithTolerance.new(line_segment.lower_left.y..line_segment.upper_left.y, world.tolerance)
        end

        def curve_potential_intersection_points
          aligned_curve_y_zero_t_values.map { |t|
            curve_segment.compute_point(t)
          }
        end

        def cosphi(t)
          return t.to_f if (-1..1).include?(t)
          t < 0 ? -1.0 : 1.0
        end

        def out_of_range?
          ->(t) { t < 0 || t > 1 }
        end

        def d
          @d ||= (-start_point_y + (3 * control_point_1_y) - (3 * control_point_2_y) + end_point_y).to_f
        end

        def d_zero?
          d == 0
        end

        def aligned_curve_y_zero_t_values
          a = ((3 * start_point_y) - (6 * control_point_1_y) + (3 * control_point_2_y)) / d
          b = ((-3 * start_point_y) + (3 * control_point_1_y)) / d
          c = start_point_y / d
          p = ((3 * b) - (a * a)) / 3.0
          third_p = p / 3.0
          q = ((2 * (a ** 3)) - (9 * a * b) + (27 * c)) / 27.0
          half_q = q / 2.0
          discriminant = (half_q ** 2) + (third_p ** 3)

          if discriminant < 0
            r = Math.sqrt((-third_p) ** 3)
            t = -q / (2 * r)
            phi = Math.acos(cosphi(t))
            t1 = 2 * cuberoot(r)
            y1 = (t1 * Math.cos(phi / 3.0)) - (a / 3.0)
            y2 = (t1 * Math.cos((phi + TAU) / 3.0)) - (a / 3.0)
            y3 = (t1 * Math.cos((phi + (2 * TAU)) / 3.0)) - (a / 3.0)
            return [y1, y2, y3].reject(&out_of_range?)
          elsif discriminant == 0
            u1 = half_q < 0 ? cuberoot(-half_q) : -cuberoot(half_q)
            y1 = (2 * u1) - (a / 3.0)
            y2 = -u1 - (a / 3.0)
            return [y1, y2].reject(&out_of_range?)
          else
            sd = Math.sqrt(discriminant)
            u1 = cuberoot(-half_q + sd)
            v1 = cuberoot(half_q + sd)
            return [u1 - v1 - (a / 3.0)].reject(&out_of_range?)
          end
        end

        def start_point_y
          aligned_curve_segment.start_point.y.to_f
        end

        def end_point_y
          aligned_curve_segment.end_point.y.to_f
        end

        def control_point_1_y
          aligned_curve_segment.control_point_1.y.to_f
        end

        def control_point_2_y
          aligned_curve_segment.control_point_2.y.to_f
        end

        def align_transform
          @align_transform ||= Transformations::Composer.compose(
            world.vector.translation_between(line_segment.start_point, world.point.zero),
            Transformations.rotate(-line_segment.radians)
          )
        end

        def aligned_curve_segment
          @aligned_curve_segment ||= curve_segment.transform(align_transform)
        end

        def aligned_line_segment
          @aligned_line_segment ||= line_segment.transform(align_transform)
        end

        def cuberoot(val)
          val < 0 ? -Math.cbrt(-val) : Math.cbrt(val)
        end
      end
    end
  end
end
