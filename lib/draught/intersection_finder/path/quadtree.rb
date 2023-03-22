require_relative '../../extent'

module Draught
  module IntersectionFinder
    class Path
      class Quadtree
        MAX_DEPTH = 10

        def self.build(extent, segment_intersection_finder, edges, depth = 0)
          culled_edges = edges.select(&edge_tester(extent, segment_intersection_finder))
          new(extent, segment_intersection_finder, culled_edges, depth)
        end

        def self.edge_tester(extent, segment_intersection_finder)
          ->(edge) {
            extent.contains?(edge.segment) || extent.overlaps?(edge.segment) && extent.edges.any? { |extent_edge|
              !segment_intersection_finder.intersections(edge.segment, extent_edge).empty?
            }
          }
        end

        attr_reader :segment_intersection_finder, :extent, :edges, :depth

        def initialize(extent, segment_intersection_finder, edges, depth)
          @extent, @segment_intersection_finder, @edges, @depth, @callback = extent, segment_intersection_finder, edges, depth
        end

        def nodes
          @nodes ||= generate_nodes
        end

        def leaf?
          depth >= MAX_DEPTH || edges.length <= 1 || edges_by_graph.length <= 1 || edges_by_graph.all? { |path, edges| edges.length == 1 }
        end

        def generate_intersection_candidates(candidate_set)
          unless leaf?
            nodes.each { |node|
              node.generate_intersection_candidates(candidate_set)
            }
            return
          end

          return if edges.length <= 1

          extent_mentioned = false
          edges_by_graph.map { |_, v| v }.combination(2).each do |graph_a_edges, graph_b_edges|
            graph_a_edges.product(graph_b_edges).each do |edge_a, edge_b|
              candidate_set << [edge_a, edge_b]
            end
          end
        end

        private

        def edges_by_graph
          @edges_by_graph ||= edges.group_by(&:graph)
        end

        def generate_nodes
          return [] if leaf?
          [:lower_left, :lower_right, :upper_left, :upper_right].map { |new_corner|
            Draught::Extent::Instance.new(extent.world, items: [extent.centre, extent.public_send(new_corner)])
          }.map { |new_extent|
            self.class.build(new_extent, segment_intersection_finder, edges, depth + 1)
          }
        end
      end
    end
  end
end
