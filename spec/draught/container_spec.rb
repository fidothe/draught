require 'draught/world'
require 'draught/container'
require 'draught/boxlike_examples'
require 'draught/spec_box'
require 'draught/point'
require 'draught/transformations'

module Draught
  RSpec.describe Container do
    let(:world) { World.new }
    let(:box) { SpecBox.new(world, lower_left: world.point.zero, width: 200, height: 100) }
    subject { Container.new(world, box, min_gap: 50) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "returns [:container] for #box_type" do
      expect(subject.box_type).to eq([:container])
    end

    it "reports the minimum gap it should have between it and any other Container" do
      expect(subject.min_gap).to eq(50)
    end

    context "min_gap and transformation" do
      specify "we assume transformations are simply uniform and the min_gap gets scaled as if it were an x co-ord" do
        transformation = Draught::Transformations::Affine.new(
          Matrix[[2,0,0],[0,2,0],[0,0,1]]
        )
        transformed = subject.transform(transformation)
        expect(transformed.min_gap).to eq(100)
      end
    end

    context "paths and containers" do
      it "returns a list containing its box for #paths" do
        expect(subject.paths).to eq([box])
      end

      it "delegates #containers to its box" do
        allow(box).to receive(:containers) { [:container] }
        expect(subject.containers).to eq([:container])
      end
    end
  end
end
