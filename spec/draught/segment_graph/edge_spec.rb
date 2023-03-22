require 'draught/world'
require 'draught/segment_graph'

module Draught::SegmentGraph
  RSpec.describe Edge do
    let(:world) { Draught::World.new }

    def p(x, y)
      world.point.new(x, y)
    end

    def l(start_point, end_point)
      world.line_segment.from_to(start_point, end_point)
    end

    let(:p1) { p(100,100) }
    let(:p2) { p(100,200) }
    let(:p3) { p(200,100) }

    let(:segment) { l(p1, p2) }
    let(:graph) { Graph.new(world, world.path.simple(p1, p2, p3)) }

    describe "creating" do
      specify "requires a graph and a segment" do
        expect(described_class.new(graph, segment)).to be_an(Edge)
      end

      specify "can be created with a previous and next edges" do
        edge_1 = described_class.new(graph, l(p3, p1))
        edge_2 = described_class.new(graph, l(p2, p3))

        expect(described_class.new(graph, segment, preceding: edge_1, following: edge_2)).to be_an(Edge)
      end
    end

    describe "basic attributes" do
      subject { described_class.new(graph, segment) }

      specify "can return their segment" do
        expect(subject.segment).to be(segment)
      end

      specify "can return their graph" do
        expect(subject.graph).to be(graph)
      end

      specify "can return their graph's world" do
        expect(subject.world).to be(world)
      end

      specify "can return their start point" do
        expect(subject.start_point).to be(p1)
      end

      specify "can return their end point" do
        expect(subject.end_point).to be(p2)
      end

      specify "reports no previous edge by default" do
        expect(subject.preceding?).to be(false)
        expect(subject.preceding).to be_nil
      end

      specify "reports no next edge by default" do
        expect(subject.following?).to be(false)
        expect(subject.following).to be_nil
      end

      context "when passed preceding/following edges" do
        let(:preceding) { described_class.new(world, l(p3, p1)) }
        let(:following) { described_class.new(world, l(p2, p3)) }
        subject { described_class.new(graph, segment, preceding: preceding, following: following) }

        specify "reports having a preceding edge" do
          expect(subject.preceding?).to be(true)
        end

        specify "can return their previous edge" do
          expect(subject.preceding).to be(preceding)
        end

        specify "reports having a next edge" do
          expect(subject.following?).to be(true)
        end

        specify "can return their next edge" do
          expect(subject.following).to be(following)
        end
      end

      describe "having preceding/following edges set" do
        let(:preceding) { described_class.new(graph, l(p3, p1)) }
        let(:following) { described_class.new(graph, l(p2, p3)) }
        subject { described_class.new(graph, segment) }

        specify "setting their preceding edge sets themself as the preceding's following edge" do
          subject.set_preceding(preceding)
          expect(subject.preceding).to be(preceding)
          expect(preceding.following).to be(subject)
        end

        specify "setting their following edge sets themself as the following's preceding edge" do
          subject.set_following(following)
          expect(subject.following).to be(following)
          expect(following.preceding).to be(subject)
        end
      end
    end
  end
end
