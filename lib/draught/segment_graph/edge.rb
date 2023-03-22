module Draught
  module SegmentGraph
    class Edge
      attr_reader :graph, :segment, :preceding, :following

      def initialize(graph, segment, preceding: nil, following: nil)
        @graph, @segment, @preceding, @following = graph, segment, preceding, following
      end

      def start_point
        segment.start_point
      end

      def end_point
        segment.end_point
      end

      def world
        graph.world
      end

      def preceding?
        !@preceding.nil?
      end

      def following?
        !@following.nil?
      end

      def set_following(edge)
        @following = edge
        edge.set_preceding_unchecked(self)
        self
      end

      def set_preceding(edge)
        @preceding = edge
        edge.set_following_unchecked(self)
        self
      end

      protected

      def set_preceding_unchecked(edge)
        @preceding = edge
      end

      def set_following_unchecked(edge)
        @following = edge
      end
    end
  end
end
