require_relative 'quadtree'
require 'set'
require_relative '../segment'
require_relative '../../segment_graph'
require_relative '../../path_intersection_point'

module Draught
  module IntersectionFinder
    class Path
      class Finder
        attr_reader :world, :segment_intersection_finder, :extent, :paths

        def initialize(world, paths)
          @world, @paths = world, paths
          @extent = Draught::Extent::Instance.from_pathlike(world, items: paths)
          @segment_intersection_finder = Draught::IntersectionFinder::Segment.new(world)
        end

        def segment_graphs
          @segment_graphs ||= paths.map { |path| Draught::SegmentGraph::Graph.new(world, path) }
        end

        def all_edges
          @all_edges ||= segment_graphs.flat_map(&:edges)
        end

        def quadtree
          @quadtree ||= Quadtree.new(extent, segment_intersection_finder, all_edges, 0)
        end

        def intersections
          candidates = Set.new
          quadtree.generate_intersection_candidates(candidates)
          candidates.flat_map { |edge_a, edge_b|
            segment_intersection_finder.intersections(edge_a.segment, edge_b.segment).map { |intersection_point|
              Draught::PathIntersectionPoint.new(world, intersection_point, [edge_a.graph.path, edge_b.graph.path])
            }
          }.compact
        end
      end
    end
  end
end
