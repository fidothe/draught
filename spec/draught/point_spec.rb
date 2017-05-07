require 'draught/point'
require 'draught/pointlike_examples'
require 'draught/cubic_bezier'
require 'draught/vector'

module Draught
  RSpec.describe Point do
    subject { Point.new(1, 2) }

    it_behaves_like "a point-like thing"

    it "returns its x" do
      expect(subject.x).to eq(1)
    end

    it "returns its y" do
      expect(subject.y).to eq(2)
    end

    specify "provides a (0,0) point via a constant" do
      expect(Point::ZERO).to eq(Point.new(0,0))
    end

    describe "manipulations in space" do
      specify "a Point can be translated using a Vector to produce a new Point" do
        translation = Vector.new(1,2)

        expect(subject.translate(translation)).to eq(Point.new(2,4))
      end

      specify "a Point can report the translation needed to relocate itself to a second Point" do
        expect(subject.translation_to(Point.new(0,0))).to eq(Vector.new(-1, -2))
      end

      specify "a Point can be transformed by a lambda-like object which takes the point and returns a new one" do
        transformer = ->(point) {
          Point.new(point.x + 1, point.y + 1)
        }

        expect(subject.transform(transformer)).to eq(Point.new(2,3))
      end

      context "Affine transformations with Matrices" do
        let(:matrix) { ::Matrix[[1],[2],[1]] }
        subject { Point.new(1,2) }

        specify "a Point can return a suitable 1-column Matrix representation of itself" do
          expect(subject.to_matrix).to eq(matrix)
        end

        specify "a Point can be constructed from a suitable 1-column Matrix representation" do
          expect(Point.from_matrix(matrix)).to eq(subject)
        end
      end
    end
  end
end
