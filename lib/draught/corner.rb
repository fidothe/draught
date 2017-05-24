require_relative './path_builder'
require_relative './vector'
require_relative './line'
require_relative './arc_builder'

module Draught
  module Corner
    class Rounded
      def self.join(args)
        new(args).join
      end

      attr_reader :radius, :paths

      def initialize(args)
        @radius = args.fetch(:radius)
        @paths = args.fetch(:paths)
      end

      def join
        new_path = []

        paths.inject do |incoming, outgoing|
          incoming_before_final_segment = incoming[0..-3]
          incoming_line = Line.from_path(incoming[-2,2])
          outgoing_after_first_segment = outgoing[2..-1]
          outgoing_line = Line.from_path(outgoing[0..1])

          incoming_corner_line = incoming_line.extend(to: 1)
          incoming_corner_line = incoming_corner_line.translate(
            Vector.translation_between(incoming_corner_line.last, Point::ZERO)
          )
          outgoing_corner_line = outgoing_line.extend(to: 1)
          outgoing_corner_line = outgoing_corner_line.translate(
            Vector.translation_between(outgoing_corner_line.first, Point::ZERO)
          )
          corner_top_line = Line.build({
            start_point: incoming_corner_line.start_point, end_point: outgoing_corner_line.end_point
          })
          corner_top_line = corner_top_line.extend(to: corner_top_line.length / 2.0)
          corner_bisection_line = Line.build({
            start_point: incoming_corner_line.end_point, end_point: corner_top_line.end_point
          })
          half_corner_angle = Math.asin(corner_top_line.length/incoming_corner_line.length)
          corner_angle = half_corner_angle * 2.0

          distance_to_tangent = radius / Math.tan(corner_angle / 2.0)

          incoming_final_segment = incoming_line.extend(by: -distance_to_tangent)
          outgoing_first_segment = outgoing_line.extend(by: -distance_to_tangent, at: :start)

          joined_lines = PathBuilder.connect(incoming_line, outgoing_line)
          zeroed_joined_lines = joined_lines.translate(Vector.translation_to_zero(joined_lines.points.first))
          aligned_zeroed_lines = zeroed_joined_lines.transform(Transformations.rotate(incoming_line.radians * -1))

          corner_angle_negative = if aligned_zeroed_lines[0].x > aligned_zeroed_lines[1].x
            aligned_zeroed_lines[0].y < aligned_zeroed_lines[2].y
          else
            aligned_zeroed_lines[0].y > aligned_zeroed_lines[2].y
          end
          arc_sweep = Math::PI - corner_angle
          if corner_angle_negative
            arc_sweep = arc_sweep * -1
            corner_angle = corner_angle * -1
          end
          starting_angle = incoming_corner_line.radians - (Math::PI / 2)

          corner_arc_path = ArcBuilder.radians(angle: arc_sweep, radius: radius, starting_angle: starting_angle).path
          corner_path = PathBuilder.connect(
            incoming_before_final_segment,
            incoming_final_segment,
            corner_arc_path,
            outgoing_first_segment,
            outgoing_after_first_segment
          )
          corner_path
        end
      end
    end
  end
end
