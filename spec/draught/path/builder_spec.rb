require 'draught/world'
require 'draught/point'
require 'draught/style'
require 'draught/path/builder'

module Draught
  RSpec.describe Path::Builder do
    let(:world) { World.new }
    let(:p1) { world.point.new(1,1) }
    let(:p2) { world.point.new(2,2) }
    let(:metadata) { Metadata::Instance.new(name: 'name') }
    subject { described_class.new(world) }

    describe "creating a new Path" do
      specify "which is empty" do
        path = subject.new
        expect(path.points).to eq([])
        expect(path.world).to be(world)
      end

      specify "from an array of Points" do
        path = subject.new(points: [p1, p2])
        expect(path.points).to eq([p1, p2])
        expect(path.world).to be(world)
      end

      specify "including Metadata" do
        path = subject.new(points: [p1, p2], metadata: metadata)
        expect(path.metadata).to be(metadata)
      end
    end

    describe "building a path via append operations" do
      it "yields an object to a block and collects points appended to it into a new Path" do
        path = subject.build { |p|
          p << p1
          p << p2
        }

        expect(path.points).to eq([p1, p2])
      end

      it "allows chaining << as Array does" do
        path = subject.build { |p|
          p << p1 << p2
        }

        expect(path.points).to eq([p1, p2])
      end

      specify "the yielded value will return the last point added if asked" do
        collector = []
        path = subject.build { |p|
          p << p1
          collector << p.last
        }

        expect(collector).to eq([p1])
      end

      specify "the yielded value will correctly return the last point even when another path was appended" do
        other_path = subject.build { |p|
          p << p1
          p << p2
        }
        collector = []

        path = subject.build { |p|
          p << p1
          p << other_path
          collector << p.last
        }

        expect(collector).to eq([p2])
      end

      context "handling Style and Annotation" do
        let(:path) {
          subject.build(metadata: metadata) { |p|
            p << p1
          }
        }

        specify "Metadata can be set" do
          expect(path.metadata).to be(metadata)
        end
      end
    end

    describe "connecting several paths together" do
      let(:horizontal) { subject.build { |p| p << world.point.new(0,0) << world.point.new(1,0) } }
      let(:diagonal) { subject.build { |p| p << world.point.new(0,0) << world.point.new(1,1) } }
      let(:spaced_horizontal) { subject.build { |p|
        p << world.point.new(2,0) << world.point.new(3,0)
      } }

      it "connects by translating the first point of the next path onto the last point of the previous and eliminating duplicates" do
        path = subject.connect(horizontal, diagonal, spaced_horizontal)

        expect(path.points).to eq([
          world.point.new(0,0), world.point.new(1,0), world.point.new(2,1), world.point.new(3,1)
        ])
      end

      it "copes if one or more of the paths to connect are empty" do
        path = subject.connect(Path.new(world), horizontal, diagonal, Path.new(world), spaced_horizontal, Path.new(world))

        expect(path.points).to eq([
          world.point.new(0,0), world.point.new(1,0), world.point.new(2,1), world.point.new(3,1)
        ])
      end

      context "handling Metadata" do
        let(:styled_horizontal) { horizontal.with_metadata(metadata) }

        context "when a path being connected has metadata, but there's no explicit metadata supplied" do
          let(:connected) { subject.connect(styled_horizontal, diagonal, spaced_horizontal) }

          specify "the resulting path has null metadata" do
            expect(connected.metadata).to_not be(metadata)
          end
        end

        context "when the builder specifies Metadata" do
          let(:joined) { subject.connect(horizontal, diagonal, spaced_horizontal, metadata: metadata) }

          specify "the resulting path has the correct Metadata" do
            expect(joined.metadata).to be(metadata)
          end
        end
      end
    end
  end
end
