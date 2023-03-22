require 'draught/world'
require 'draught/segment_graph'

module Draught::SegmentGraph
  RSpec.describe Graph do
    let(:world) { Draught::World.new }

    def p(x, y)
      world.point.new(x, y)
    end

    describe "representing an open path" do
      let(:path) { world.path.simple(p(100,100), p(200,200), p(300,100), p(200,0)) }
      subject { described_class.new(world, path) }

      specify "can return its path" do
        expect(subject.path).to be(path)
      end

      specify "can return its first edge" do
        starting_edge = subject.starting_edge
        expect(starting_edge.start_point).to eq(p(100,100))
        expect(starting_edge.end_point).to eq(p(200,200))
      end

      specify "can return all its edges" do
        expect(subject.edges.size).to eq(3)
      end

      specify "edges are in the correct order" do
        edge = subject.starting_edge
        edges = [edge]
        while edge.following?
          edge = edge.following
          edges << edge
        end

        expect(edges.map(&:segment)).to eq(path.segments)
      end
    end
  end
end