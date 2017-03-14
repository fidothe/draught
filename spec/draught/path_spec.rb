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
      expect(path.to_a).to eq([point])
    end

    specify "adding a point to the path returns a new path" do
      path = subject << point

      expect(path.to_a).to eq([point])
      expect(subject).to be_empty
    end

    specify "adding several points to the path returns a new path" do
      other_point = Point.new(2,2)

      path = subject.add_points([point, other_point])

      expect(path.to_a).to eq([point, other_point])
      expect(subject).to be_empty
    end
  end
end
