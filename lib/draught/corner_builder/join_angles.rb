require_relative '../arc_builder'

module Draught
  class CornerBuilder
    class JoinAngles
      attr_reader :world, :incoming_line_segment, :outgoing_line_segment

      def initialize(world, incoming_line_segment, outgoing_line_segment)
        @world = world
        @incoming_line_segment = incoming_line_segment
        @outgoing_line_segment = outgoing_line_segment
      end

      def arc_sweep
        anticlockwise? ? abs_arc_sweep : abs_arc_sweep * -1
      end

      def tangent_distance(radius)
        radius / Math.tan(abs_corner_angle / 2.0)
      end

      private

      def abs_corner_angle
        @abs_corner_angle ||= begin
          half_corner_angle = Math.asin(corner_top_line_segment.length/incoming_corner_line_segment.length)
          half_corner_angle * 2.0
        end
      end

      def corner_top_line_segment
        @corner_top_line_segment ||= begin
          corner_top_line_segment = world.line_segment.build(
            start_point: incoming_corner_line_segment.start_point, end_point: outgoing_corner_line_segment.end_point
          )
          corner_top_line_segment.extend(to: corner_top_line_segment.length / 2.0)
        end
      end

      def incoming_corner_line_segment
        @incoming_corner_line_segment ||= zeroed_unit_line_segment(incoming_line_segment, :end_point)
      end

      def outgoing_corner_line_segment
        @outgoing_corner_line_segment ||= zeroed_unit_line_segment(outgoing_line_segment, :start_point)
      end

      def zeroed_unit_line_segment(segment, zero_to_point)
        unit_line_segment = segment.extend(to: 1)
        unit_line_segment.translate(
          world.vector.translation_to_zero(unit_line_segment.public_send(zero_to_point))
        )
      end

      def abs_arc_sweep
        @abs_arc_sweep ||= Math::PI - abs_corner_angle
      end

      def anticlockwise?
        !clockwise?
      end

      def clockwise?
        if aligned_zeroed_joined_points[0].x > aligned_zeroed_joined_points[1].x
          aligned_zeroed_joined_points[0].y < aligned_zeroed_joined_points[2].y
        else
          aligned_zeroed_joined_points[0].y > aligned_zeroed_joined_points[2].y
        end
      end

      def aligned_zeroed_joined_points
        @aligned_zeroed_joined_points ||= begin
          joined_line_path = world.path.connect(incoming_line_segment, outgoing_line_segment)
          zeroed_joined_line_segments = joined_line_path.translate(world.vector.translation_to_zero(joined_line_path.first))
          zeroed_joined_line_segments.transform(Transformations.rotate(incoming_line_segment.radians * -1)).points
        end
      end
    end
  end
end
