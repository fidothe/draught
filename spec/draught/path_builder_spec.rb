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
  end
end
