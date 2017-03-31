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

    specify "provides a (0,0) point via a constant" do
      expect(Point::ZERO).to eq(Point.new(0,0))
    end

    describe "comparisons" do
      context "equality" do
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
    end

    describe "manipulations in space" do
      specify "a Point can be translated using a second Point to produce a new Point" do
        translation = Point.new(1,2)

        expect(subject.translate(translation)).to eq(Point.new(2,4))
      end

      specify "a Point can report the translation needed to relocate itself to a second Point" do
        expect(subject.translation_to(Point.new(0,0))).to eq(Point.new(-1, -2))
      end

      context "Affine transformations with Matrices" do
        subject { Point.new(1,2) }

        specify "a Point can return a suitable 1-column Matrix representation of itself" do
          expect(subject.to_matrix).to eq(Matrix[[1],[2],[1]])
        end

        specify "a Point can be transformed by a 3x3 affine transformation matrix" do
          reflect_around_x_axis = Matrix[
            [1,  0, 0],
            [0, -1, 0],
            [0,  0, 1]
          ]
          expect(subject.transform(reflect_around_x_axis)).to eq(Point.new(1,-2))
        end
      end
    end
  end
end
