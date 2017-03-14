require 'draught/point'
require 'draught/path'

module Draught
  RSpec.describe Path do
    let(:point) { Point.new(1,1) }

    it "contains no points by default" do
      expect(subject.empty?).to be(true)
    end

    it "can be initialized with an array of Points" do
      path = Path.new([point])

      expect(path.empty?).to be(false)
    end

    it "can return an array of its points" do
      path = Path.new([point])

      expect(path.points).to eq([point])
    end

    specify "appending a point to the path returns a new path" do
      path = subject.append(point)

      expect(path.points).to eq([point])
      expect(subject).to be_empty
    end

    specify "appending several points to the path returns a new path" do
      other_point = Point.new(2,2)

      path = subject.append(point, other_point)

      expect(path.points).to eq([point, other_point])
    end

    it "appending another path returns a new path with the other path's points appended" do
      other_point = Point.new(2,2)
      first_path = Path.new([point])
      other_path = Path.new([other_point])

      path = first_path << other_path

      expect(path.points).to eq([point, other_point])
    end

    it "provides a convenience block form path-builder" do
      path = Path.build { |p|
        p << point
        p << point
      }

      expect(path.points).to eq([point, point])
    end
  end
end
