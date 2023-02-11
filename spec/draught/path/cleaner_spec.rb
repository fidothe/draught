require 'draught/path/cleaner'
require 'draught/world'

module Draught
  RSpec.describe Path::Cleaner do
    let(:world) { World.new }
    let(:metadata) { Metadata::Instance.new(name: 'name') }

    def p(x, y)
      world.point.new(x, y)
    end

    describe "cleaning a path by removing extra identical points" do
      specify "returns a new cleaned path" do
        input = world.path.new(points: [p(0,0), p(1,0), p(1,0), p(4,0)])
        expected = world.path.new(points: [p(0,0), p(1,0), p(4,0)])

        expect(described_class.dedupe(world, input)).to eq(expected)
      end

      context "handling Metadata" do
        let(:input) { world.path.new(points: [p(0,0), p(4,0), p(1,0)], metadata: metadata) }
        let(:deduped) { described_class.dedupe(world, input) }

        specify "preserves Metadata" do
          expect(deduped.metadata).to be(metadata)
        end
      end
    end

    describe "simplifying a path" do
      let(:expected) { world.path.new(points: [p(0,0), p(4,0), p(4,4)]) }

      it "removes unnecessary intermediate points on the horizontal" do
        input = world.path.new(points: [p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the horizontal" do
        input = world.path.new(points: [p(0,0), p(1,0), p(1,0), p(2,0), p(3,0), p(4,0), p(4,4)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "removes unnecessary intermediate points on the vertical" do
        input = world.path.new(points: [p(0,0), p(4,0), p(4,1), p(4,2), p(4,4)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "goes around corners" do
        input = world.path.new(points: [p(0,0), p(1,0), p(3,0), p(4,0), p(4,2), p(4,4)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "does not remove points where it's not obvious which point to remove" do
        input = world.path.new(points: [p(0,0), p(4,0), p(1,0)])
        expected = world.path.new(points: [p(0,0), p(4,0), p(1,0)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "copes with paths proceeding right-to-left" do
        input = world.path.new(points: [p(4,0), p(2,0), p(1,0)])
        expected = world.path.new(points: [p(4,0), p(1,0)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end

      it "copes with paths proceeding top-to-bottom" do
        input = world.path.new(points: [p(0,4), p(0,2), p(0,1)])
        expected = world.path.new(points: [p(0,4), p(0,1)])

        expect(described_class.simplify(world, input)).to eq(expected)
      end


      context "handling Metadata" do
        let(:input) { world.path.new(points: [p(0,0), p(4,0), p(1,0)], metadata: metadata) }
        let(:deduped) { described_class.simplify(world, input) }

        specify "preserves Metadata" do
          expect(deduped.metadata).to be(metadata)
        end
      end
    end
  end
end
