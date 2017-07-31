require_relative './path_builder'
require_relative './vector'
require_relative './line'
require_relative './arc_builder'

module Draught
  class Corner
    def self.join_rounded(args)
      new(args).join
    end

    attr_reader :radius, :paths

    def initialize(args)
      @radius = args.fetch(:radius)
      @paths = args.fetch(:paths)
    end

    def join
      paths.inject { |incoming, outgoing|
        Rounded.join(radius: radius, incoming: incoming, outgoing: outgoing)
      }
    end

    class Rounded
      def self.join(args)
        new(args).joined
      end

      attr_reader :radius, :incoming, :outgoing

      def initialize(args)
        @radius = args.fetch(:radius)
        @incoming = args.fetch(:incoming)
        @outgoing = args.fetch(:outgoing)
      end

      def joined
        PathBuilder.connect(
          incoming_before_final_segment,
          incoming_final_segment,
          corner_arc_path,
          outgoing_first_segment,
          outgoing_after_first_segment
        )
      end

      def incoming_before_final_segment
        incoming[0..-2]
      end

      def incoming_final_segment
        incoming_line.extend(by: -distance_to_tangent)
      end

      def incoming_line
        Line.from_path(incoming[-2,2])
      end

      def outgoing_first_segment
        outgoing_line.extend(by: -distance_to_tangent, at: :start)
      end

      def outgoing_line
        Line.from_path(outgoing[0..1])
      end

      def outgoing_after_first_segment
        outgoing[1..-1]
      end

      def distance_to_tangent
        @distance_to_tangent ||= join_angles.tangent_distance(radius)
      end

      def join_angles
        @join_angles ||= JoinAngles.new(incoming_line, outgoing_line)
      end

      def corner_arc_path
        ArcBuilder.radians(angle: join_angles.arc_sweep, radius: radius, starting_angle: starting_angle).path
      end

      def starting_angle
        incoming_line.radians - (Math::PI / 2)
      end
    end

    class JoinAngles
      attr_reader :incoming_line, :outgoing_line

      def initialize(incoming_line, outgoing_line)
        @incoming_line = incoming_line
        @outgoing_line = outgoing_line
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
          half_corner_angle = Math.asin(corner_top_line.length/incoming_corner_line.length)
          half_corner_angle * 2.0
        end
      end

      def corner_top_line
        @corner_top_line ||= begin
          corner_top_line = Line.build({
            start_point: incoming_corner_line.start_point, end_point: outgoing_corner_line.end_point
          })
          corner_top_line.extend(to: corner_top_line.length / 2.0)
        end
      end

      def incoming_corner_line
        @incoming_corner_line ||= zeroed_unit_line_segment(incoming_line, :last)
      end

      def outgoing_corner_line
        @outgoing_corner_line ||= zeroed_unit_line_segment(outgoing_line, :first)
      end

      def zeroed_unit_line_segment(segment, zero_to_point)
        unit_line_segment = segment.extend(to: 1)
        unit_line_segment.translate(
          Vector.translation_to_zero(unit_line_segment.public_send(zero_to_point))
        )
      end

      def abs_arc_sweep
        @abs_arc_sweep ||= Math::PI - abs_corner_angle
      end

      def anticlockwise?
        !clockwise?
      end

      def clockwise?
        if aligned_zeroed_lines[0].x > aligned_zeroed_lines[1].x
          aligned_zeroed_lines[0].y < aligned_zeroed_lines[2].y
        else
          aligned_zeroed_lines[0].y > aligned_zeroed_lines[2].y
        end
      end

      def aligned_zeroed_lines
        @aligned_zeroed_lines ||= begin
          joined_lines = PathBuilder.connect(incoming_line, outgoing_line)
          zeroed_joined_lines = joined_lines.translate(Vector.translation_to_zero(joined_lines.first))
          zeroed_joined_lines.transform(Transformations.rotate(incoming_line.radians * -1))
        end
      end
    end
  end
end
