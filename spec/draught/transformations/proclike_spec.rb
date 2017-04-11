require 'draught/transformations/proclike'
require 'draught/transformations/shared_examples'
require 'draught/point'

module Draught::Transformations
  RSpec.describe Proclike do
    let(:array_return_transformer) { ->(p) { [2 * p.x, 2 * p.y] } }
    let(:point_return_transformer) { ->(p) { Draught::Point.new(p.x + 10, p.y + 10) } }
    let(:input_point) { Draught::Point.new(1,2) }
    let(:expected_point) { Draught::Point.new(11,12) }

    subject { Proclike.new(point_return_transformer) }

    include_examples "transformation object fundamentals"
    include_examples "producing a transform-compatible verison of itself"

    describe "running the transformation with #call() and passing in a Point" do
      it "returns the result as a Point if the block returns an [x,y] tuple" do
        expect(Proclike.new(array_return_transformer).call(input_point)).
          to eq(Draught::Point.new(2,4))
      end
    end

    specify "the transform is not Affine" do
      expect(Proclike.new(array_return_transformer).affine?).to be false
    end

    specify "Proclike transforms cannot be coalesced, so raise TypeError if asked to" do
      expect { subject.coalesce(subject) }.to raise_error(TypeError)
    end

    context "composition" do
      let(:other_transform) { Proclike.new(array_return_transformer) }
      let(:expected_point) { Draught::Point.new(12,14) }

      include_examples "composable with another transform"
    end
  end
end
