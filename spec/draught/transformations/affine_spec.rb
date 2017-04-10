require 'draught/transformations/affine'
require 'draught/transformations/proclike'
require 'draught/transformations/shared_examples'
require 'draught/point'

module Draught::Transformations
  RSpec.describe Affine do
    let(:transformation_matrix) {
      Matrix[[-1, 0, 0],[0, -1, 0],[0,0,1]]
    }
    let(:input_point) { Draught::Point.new(1,2) }
    let(:result_point) { Draught::Point.new(-1,-2) }

    subject { Affine.new(transformation_matrix) }

    it_should_behave_like "a well-behaved transformation class"

    it "claims to be affine" do
      expect(Affine.new(transformation_matrix).affine?).to be true
    end

    context "coalescing two Affine transforms together into a new transform" do
      let(:t1) { Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]]) }
      let(:t2) { Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

      specify "produces a new Affine transform by matrix multiplication" do
        expect(t2.coalesce(t1).call(input_point)).to eq(Draught::Point.new(-1,-2))
      end

      specify "the matrix of the new transform is the product of the inputs" do
        expected_matrix = Matrix[[-1, 0, 0],[0, -1, 0],[0, 0, 1]]

        coalesced = t2.coalesce(t1)

        expect(coalesced.transformation_matrix).to eq(expected_matrix)
      end

      specify "attempting to coalesce an Affine transform with another kind raises TypeError" do
        other = Proclike.new(->(p) { p })

        expect { subject.coalesce(other) }.to raise_error(TypeError)
      end
    end

    specify "two Affine transforms can be composed into a single one" do
      t1 = Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]])
      t2 = Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]])

      expect(t2.compose(t1).call(input_point)).to eq(Draught::Point.new(-1,-2))
    end

    specify "an Affine transform can be composed with a Proclike" do
      t1 = Proclike.new(->(p) { [p.x + 2, p.y + 2] })
      t2 = Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]])

      expect(t2.compose(t1).call(input_point)).to eq(Draught::Point.new(3,-4))
    end
  end
end
