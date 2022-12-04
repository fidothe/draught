require 'draught/point'
require 'draught/world'
require 'draught/pointlike_examples'
require 'draught/cubic_bezier'
require 'draught/vector'

module Draught
  RSpec.describe Point do
    let(:world) { World.new }
    subject { Point.new(1, 2, world) }

    it_behaves_like "a point-like thing"

    it "returns its x" do
      expect(subject.x).to eq(1)
    end

    it "returns its y" do
      expect(subject.y).to eq(2)
    end

    describe "manipulations in space" do
      specify "a Point can be translated using a Vector to produce a new Point" do
        translation = world.vector.new(1,2)

        expect(subject.translate(translation)).to eq(Point.new(2, 4, world))
      end

      specify "a Point can report the translation needed to relocate itself to a second Point" do
        expect(subject.translation_to(Point.new(0, 0, world))).to eq(world.vector.new(-1, -2))
      end

      specify "a Point can be transformed by a lambda-like object which takes the point and returns a new one" do
        transformer = ->(point, world) {
          world.point.new(point.x + 1, point.y + 1)
        }

        expect(subject.transform(transformer)).to eq(Point.new(2, 3, world))
      end

      context "Affine transformations with Matrices" do
        let(:matrix) { ::Matrix[[1],[2],[1]] }

        specify "a Point can return a suitable 1-column Matrix representation of itself" do
          expect(subject.to_matrix).to eq(matrix)
        end
      end
    end

    describe "pretty printing" do
      specify "a point generates a simple x,y string" do
        expect(subject).to pp_as("1,2\n")
      end
    end
  end
end
