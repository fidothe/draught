require 'draught/point'

module Draught
  RSpec.describe Point do
    subject { Point.new(1, 2) }

    it "returns its x" do
      expect(subject.x).to eq(1)
    end

    it "returns its y" do
      expect(subject.y).to eq(2)
    end

    it "can return itself as an array of points" do
      expect(subject.points).to eq([subject])
    end

    describe "equality" do
      let(:p1) { Point.new(1,1) }
      let(:p2) { Point.new(1,1) }
      let(:p3) { Point.new(1,2) }

      specify "a Point is equal to another point if they have the same x,y co-ordinates" do
        expect(p1 == p2).to be(true)
      end

      specify "a Point is not equal to another point if their co-ordinates differ" do
        expect(p1 == p3).to be(false)
      end
    end

    describe "manipulations in space" do
      specify "a Point can be translated using a second Point to produce a new Point" do
        translation = Point.new(1,2)

        expect(subject.translate(translation)).to eq(Point.new(2,4))
      end
    end
  end
end
