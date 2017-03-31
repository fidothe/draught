require 'draught/container'
require 'draught/boxlike_examples'
require 'draught/spec_box'
require 'draught/point'

module Draught
  RSpec.describe Container do
    let(:box) { SpecBox.new(lower_left: Point::ZERO, width: 200, height: 100) }
    subject { Container.new(box, min_gap: 50) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "reports the minimum gap it should have between it and any other Container" do
      expect(subject.min_gap).to eq(50)
    end

    context "min_gap and transformation" do
      specify "we assume transformations are simply uniform and the min_gap gets scaled as if it were an x co-ord" do
        transformed = subject.transform(Matrix[[2,0,0],[0,2,0],[0,0,1]])
        expect(transformed.min_gap).to eq(100)
      end
    end

    context "paths and containers" do
      it "delegates #paths to its box" do
        allow(box).to receive(:paths) { [:path] }
        expect(subject.paths).to eq([:path])
      end

      it "delegates #containers to its box" do
        allow(box).to receive(:containers) { [:container] }
        expect(subject.containers).to eq([:container])
      end
    end
  end
end
