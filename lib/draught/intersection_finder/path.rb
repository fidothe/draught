require_relative 'path/finder'

module Draught
  module IntersectionFinder
    # Find intersections between paths
    class Path
      # @!attribute [r] world
      #   @return [Draught::World] the world
      attr_reader :world

      # @param world [Draught::World] the world
      def initialize(world)
        @world = world
      end

      # Find and returns intersections between +paths+.
      #
      # @param paths [Array<Draught::Path>]
      # @return [Array<Draught::PathIntersectionPoint>]
      def intersections(*paths)
        Finder.new(world, paths).intersections
      end
    end
  end
end
