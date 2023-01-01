require 'draught/world'
require 'draught/point'
require 'draught/style'
require 'draught/path_builder'

module Draught
  RSpec.describe PathBuilder do
    let(:world) { World.new }
    let(:p1) { world.point.new(1,1) }
    let(:p2) { world.point.new(2,2) }
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

      specify "including Style" do
        style = Style.new(stroke_color: 'hot pink')
        path = subject.new(points: [p1, p2], style: style)
        expect(path.style).to eq(style)

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

      specify "Style can be set" do
        style = Style.new(stroke_color: 'hot pink')
        path = subject.build(style) { |p|
          p << p1
        }

        expect(path.style).to be(style)
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
    end
  end
end
