require_relative './join_angles'
require_relative '../arc_builder'
require_relative '../metadata'

module Draught
  class CornerBuilder
    class Rounded
      def self.join(world, args)
        new(world, args).joined
      end

      attr_reader :world, :radius, :incoming, :outgoing

      def initialize(world, args)
        @world = world
        @radius = args.fetch(:radius)
        @incoming = args.fetch(:incoming).to_path
        @outgoing = args.fetch(:outgoing).to_path
        @metadata = args.fetch(:metadata, nil)
      end

      def joined
        world.path.connect(
          incoming_before_final_segment,
          incoming_final_segment,
          corner_arc_path,
          outgoing_first_segment,
          outgoing_after_first_segment,
          metadata: metadata
        )
      end

      def metadata
        @metadata ||= Metadata::BLANK
      end

      def incoming_before_final_segment
        incoming[0..-2]
      end

      def incoming_final_segment
        incoming_line_segment.extend(by: -distance_to_tangent)
      end

      def incoming_line_segment
        world.line_segment.from_path(incoming[-2,2])
      end

      def outgoing_first_segment
        outgoing_line_segment.extend(by: -distance_to_tangent, at: :start)
      end

      def outgoing_line_segment
        world.line_segment.from_path(outgoing[0..1])
      end

      def outgoing_after_first_segment
        outgoing[1..-1]
      end

      def distance_to_tangent
        @distance_to_tangent ||= join_angles.tangent_distance(radius)
      end

      def join_angles
        @join_angles ||= JoinAngles.new(world, incoming_line_segment, outgoing_line_segment)
      end

      def arc_builder
        @arc_builder ||= ArcBuilder.new(world)
      end

      def corner_arc_path
        arc_builder.radians(angle: join_angles.arc_sweep, radius: radius, starting_angle: starting_angle).to_path
      end

      def starting_angle
        incoming_line_segment.radians - (Math::PI / 2)
      end
    end
  end
end
