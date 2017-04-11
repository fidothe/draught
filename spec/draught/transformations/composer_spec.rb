require 'draught/transformations/composer'
require 'draught/transformations/affine'
require 'draught/transformations/proclike'
require 'draught/point'
require 'draught/transformations/shared_examples'

module Draught::Transformations
  RSpec.describe Composer do
    let(:t1) { Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]]) }
    let(:t2) { Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

    it "is initialized with a pair of transforms" do
      expect(Composer.new(t2, t1)).to be_a(Composer)
    end

    it "compares equality based on its transforms" do
      expect(Composer.new(t2, t1)).to eq(Composer.new(t2, t1))
    end

    context "behaving like a transform" do
      let(:input_point) { Draught::Point.new(1,2) }
      let(:expected_point) { Draught::Point.new(-1,-2) }
      subject { Composer.new(t1, t2) }

      include_examples "transformation object fundamentals"
    end

    context "optimisations" do
      let(:t3) { Affine.new(Matrix[[2, 0, 0],[0, 2, 0],[0, 0, 1]]) }
      let(:composed) { Composer.new(t1, t2) }
      let(:input) { Draught::Point.new(1,2) }
      let(:expected) { Draught::Point.new(-2,-4) }

      it "can flatten the transforms from composed Composer objects into a single Composer array" do
        composer = Composer.new(composed, t3)

        expect(composer.flattened_transforms).to eq([t1, t2, t3])
      end

      context "coalescing transforms" do
        let(:pt) { Proclike.new(->(p) { p }) }
        let(:t1_t2_coalesced) { Affine.new(Matrix[[-1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

        context "coalescing the transforms" do
          it "can coalesce a sequence of Affine transforms into a single transform" do
            expect(composed.coalesced_transforms).to eq([t1_t2_coalesced])
          end

          it "copes when a non-Affine transform begins the sequence" do
            composer = Composer.new(pt, t1, t2)

            expect(composer.coalesced_transforms).to eq([pt, t1_t2_coalesced])
          end

          it "copes with an empty transforms list" do
            composer = Composer.new()

            expect(composer.coalesced_transforms).to eq([])
          end

          it "copes with a single-item transform list" do
            composer = Composer.new(pt)

            expect(composer.coalesced_transforms).to eq([pt])
          end

          it "copes when a non-Affine transform ends the sequence" do
            composer = Composer.new(t1, t2, pt)

            expect(composer.coalesced_transforms).to eq([t1_t2_coalesced, pt])
          end

          it "can coalesce either side of a non-Affine transform" do
            composer = Composer.new(t1, t2, pt, t1, t2)

            expect(composer.coalesced_transforms).to eq([t1_t2_coalesced, pt, t1_t2_coalesced])
          end

          it "copes with multiple proclike transforms" do
            composer = Composer.new(pt, pt)

            expect(composer.coalesced_transforms).to eq([pt, pt])
          end
        end

        it "can return a coalesced version of itself" do
          coalesced = composed.coalesce

          expect(coalesced.transforms).to eq([t1_t2_coalesced])
        end

        it "offers a convenience creator that returns a coalesced composed version of its passed transforms" do
          expect(Composer.coalesced(t1, t2)).to eq(Composer.new(t1_t2_coalesced))
        end
      end
    end
  end
end
