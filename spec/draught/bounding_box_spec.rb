require 'draught/bounding_box'
require 'draught/path'

module Draught
  RSpec.describe BoundingBox do
    let(:input_path) { Path.new([Point.new(-1, -1), Point.new(3,3)]) }
    subject { BoundingBox.new(input_path) }

    it "returns the width of the path" do
      expect(subject.width).to eq(4)
    end

    it "returns the height of the path" do
      expect(subject.height).to eq(4)
    end

    it "can return its paths" do
      expect(subject.paths).to eq([input_path])
    end

    it "can be translated" do
      translated = subject.translate(Point.new(1,0))
      expected = [Path.new([Point.new(0,-1), Point.new(4,3)])]

      expect(translated.paths).to eq(expected)
    end
  end
end
