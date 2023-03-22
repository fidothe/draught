module Draught
  module SegmentGraph
    class Graph
      attr_reader :world, :path

      def initialize(world, path)
        @world, @path = world, path
      end

      def starting_edge
        @starting_edge ||= edges.first
      end

      def edges
        @edges ||= build_graph
      end

      private

      def build_graph
        edges = []
        path.segments.inject(nil) { |previous_edge, segment|
          edge = Edge.new(self, segment)
          edge.set_preceding(previous_edge) if previous_edge
          edges << edge
          edge
        }
        edges
      end
    end
  end
end