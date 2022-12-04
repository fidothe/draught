require 'draught/point_builder'
require 'draught/world'

module Draught
  RSpec.describe PointBuilder do
    let(:world) { World.new }
    subject { PointBuilder.new(world) }

    specify "can generate a Point in the correct World" do
      point = subject.new(1,2)
      expect(point.x).to eq(1)
      expect(point.y).to eq(2)
      expect(point.world).to be(world)
    end

    specify "provides a (0,0) point via a method" do
      expect(subject.zero).to eq(subject.new(0,0))
    end

    context "Affine transformations with Matrices" do
      let(:matrix) { ::Matrix[[1],[2],[1]] }
      let(:point) { subject.new(1, 2) }

      specify "a Point can be constructed from a suitable 1-column Matrix representation" do
        expect(subject.from_matrix(matrix)).to eq(point)
      end
    end
  end
end
