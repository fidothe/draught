require 'draught/transformations/composer'
require 'draught/transformations/affine'
require 'draught/transformations/proclike'
require 'draught/point'

module Draught::Transformations
  RSpec.describe Composer do
    let(:t1) { Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]]) }
    let(:t2) { Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]]) }
    let(:t3) { Affine.new(Matrix[[2, 0, 0],[0, 2, 0],[0, 0, 1]]) }
    let(:t1_t2_coalesced) { Affine.new(Matrix[[-1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

    subject { Composer.new([t1, t2]) }

    it "can return a Composition containing the coalesced transforms" do
      composition = subject.composition

      expect(composition.transforms).to eq([t1_t2_coalesced])
    end

    it "can flatten the transforms from composed Composer objects into an array" do
      composer = Composer.new([subject.composition, t3])

      expect(composer.flattened_transforms).to eq([t1_t2_coalesced, t3])
    end

    describe "coalescing transforms" do
      let(:pt) { Proclike.new(->(p) { p }) }

      it "can coalesce a sequence of Affine transforms into a single transform" do
        expect(subject.coalesced_transforms).to eq([t1_t2_coalesced])
      end

      it "copes when a non-Affine transform begins the sequence" do
        composer = Composer.new([pt, t1, t2])

        expect(composer.coalesced_transforms).to eq([pt, t1_t2_coalesced])
      end

      it "copes with an empty transforms list" do
        composer = Composer.new([])

        expect(composer.coalesced_transforms).to eq([])
      end

      it "copes with a single-item transform list" do
        composer = Composer.new([pt])

        expect(composer.coalesced_transforms).to eq([pt])
      end

      it "copes when a non-Affine transform ends the sequence" do
        composer = Composer.new([t1, t2, pt])

        expect(composer.coalesced_transforms).to eq([t1_t2_coalesced, pt])
      end

      it "can coalesce either side of a non-Affine transform" do
        composer = Composer.new([t1, t2, pt, t1, t2])

        expect(composer.coalesced_transforms).to eq([t1_t2_coalesced, pt, t1_t2_coalesced])
      end

      it "copes with multiple proclike transforms" do
        composer = Composer.new([pt, pt])

        expect(composer.coalesced_transforms).to eq([pt, pt])
      end
    end

    it "offers a convenience creator that returns a coalesced composed version of its passed transforms" do
      expect(Composer.compose(t1, t2)).to eq(Composer.new([t1_t2_coalesced]).composition)
    end
  end
end
