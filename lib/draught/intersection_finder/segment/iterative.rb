module Draught
  module IntersectionFinder
    class Segment
      class Iterative
        FLATNESS_TOLERANCE = 0.01

        def self.intersections(world, curve_1, curve_2)
          new(world, curve_1, curve_2).intersections
        end

        attr_reader :world, :curve_1, :curve_2

        def initialize(world, curve_1, curve_2)
          @world, @curve_1, @curve_2 = world, curve_1, curve_2
        end

        def intersections
          if both_curves_flat?
            LineLine.intersections(world, curve_1.line, curve_2.line)
          else
            return [] unless curve_1.overlaps?(curve_2)
            # split curve 1 and 2
            split_curve_1 = curve_1.split(0.5)
            split_curve_2 = curve_2.split(0.5)
            split_curve_1.flat_map { |c1|
              split_curve_2.map { |c2|
                [c1, c2]
              }
            }.flat_map { |c1, c2|
              self.class.intersections(world, c1, c2)
            }.compact
          end
        end

        private

        # https://jeremykun.com/2013/05/11/bezier-curves-and-picasso/
        # var curve = [[1,2], [5,5], [4,0], [9,3]];
        def curve_flat?(curve)
          curve.line? || calculate_curve_flatness(curve) <= FLATNESS_TOLERANCE
        end

        def calculate_curve_flatness(curve)
          ax = 3.0 * curve.control_point_1.x - 2.0 * curve.start_point.x - curve.end_point.x
          ax =  ax * ax
          ay = 3.0 * curve.control_point_1.y - 2.0 * curve.start_point.y - curve.end_point.y
          ay = ay * ay
          bx = 3.0 * curve.control_point_2.x - curve.start_point.x - 2.0 * curve.end_point.x
          bx = bx * bx
          by = 3.0 * curve.control_point_2.y - curve.start_point.y - 2.0 * curve.end_point.y
          by = by * by

          [ax, bx].max + [ay, by].max
        end

        def both_curves_flat?
          curve_flat?(curve_1) && curve_flat?(curve_2)
        end
      end
    end
  end
end
