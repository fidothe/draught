require_relative './path_builder'
require_relative './vector'
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
          incoming_pre_join_path = incoming[0..-2]
          incoming_join_point = incoming.last.translate(Vector.new(-radius,0))
          outgoing_post_join_path = outgoing[1..-1]
          outgoing_join_point = outgoing.first.translate(Vector.new(0, radius))
          corner_path = ArcBuilder.degrees(angle: 90, radius: radius, starting_angle: 270).path
          incoming_translation = Vector.translation_between(corner_path.first, incoming_join_point)
          intermediate_path = PathBuilder.build { |p|
            p << incoming_pre_join_path
            p << corner_path.translate(incoming_translation)
          }
          outgoing_translation = Vector.translation_between(outgoing_join_point, intermediate_path.last)
          intermediate_path << outgoing_post_join_path.translate(outgoing_translation)
        end
      end
    end
  end
end
