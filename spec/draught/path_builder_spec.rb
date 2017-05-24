require 'draught/point'
require 'draught/path_builder'

module Draught
  RSpec.describe PathBuilder do
    let(:p1) { Point.new(1,1) }
    let(:p2) { Point.new(2,2) }

    it "yields an object to a block and collects points appended to it into a new Path" do
      path = PathBuilder.build { |p|
        p << p1
        p << p2
      }

      expect(path.points).to eq([p1, p2])
    end

    it "allows chaining << as Array does" do
      path = PathBuilder.build { |p|
        p << p1 << p2
      }

      expect(path.points).to eq([p1, p2])
    end

    specify "the yielded value will return the last point added if asked" do
      collector = []
      path = PathBuilder.build { |p|
        p << p1
        collector << p.last
      }

      expect(collector).to eq([p1])
    end

    specify "the yielded value will correctly return the last point even when another path was appended" do
      other_path = PathBuilder.build { |p|
        p << p1
        p << p2
      }
      collector = []

      path = PathBuilder.build { |p|
        p << p1
        p << other_path
        collector << p.last
      }

      expect(collector).to eq([p2])
    end

    describe "connecting several paths together" do
      let(:horizontal) { PathBuilder.build { |p| p << Point.new(0,0) << Point.new(1,0) } }
      let(:diagonal) { PathBuilder.build { |p| p << Point.new(0,0) << Point.new(1,1) } }
      let(:spaced_horizontal) { PathBuilder.build { |p|
        p << Point.new(2,0) << Point.new(3,0)
      } }

      it "connects by translating the first point of the next path onto the last point of the previous and eliminating duplicates" do
        path = PathBuilder.connect(horizontal, diagonal, spaced_horizontal)

        expect(path.points).to eq([
          Point.new(0,0), Point.new(1,0), Point.new(2,1), Point.new(3,1)
        ])
      end

      it "copes if one or more of the paths to connect are empty" do
        path = PathBuilder.connect(Path.new, horizontal, diagonal, Path.new, spaced_horizontal, Path.new)

        expect(path.points).to eq([
          Point.new(0,0), Point.new(1,0), Point.new(2,1), Point.new(3,1)
        ])
      end
    end
  end
end
