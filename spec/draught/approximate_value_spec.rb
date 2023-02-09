require 'draught/approximate_value'

module Draught
  RSpec.describe ApproximateValue do
    subject { ApproximateValue.new(1) }

    context "defaults" do
      specify "a precision of 6 decimal places" do
        expect(subject.precision).to eq(6)
      end

      specify "a delta of 0.000001" do
        expect(subject.delta).to eq(0.000001)
      end
    end

    it "is approximately 1.000001" do
      expect(subject.is_approximately?(1.000001)).to be(true)
    end

    it "is not approximately 1.00001" do
      expect(subject.is_approximately?(1.00001)).to be(false)
    end

    it "allows a different delta to be set" do
      subject = ApproximateValue.new(1, 0.0000001)
      expect(subject.is_approximately?(1.000001)).to be(false)
    end

    it "allows a different delta and precision (in decimal places) to be set" do
      subject = ApproximateValue.new(1, 0.0000001, 7)
      expect(subject.is_approximately?(1.000001)).to be(false)
    end

    context "deltas and precisions that don't line up" do
      context "10 plus-or-minus 5, to 2 d.p." do
        subject { ApproximateValue.new(10, 5, 2) }

        specify "15.001 is in tolerance" do
          expect(subject.is_approximately?(15.001)).to be(true)
        end

        specify "15.01 is out of tolerance" do
          expect(subject.is_approximately?(15.01)).to be(false)
        end

        specify "4.999 is in tolerance" do
          expect(subject.is_approximately?(4.999)).to be(true)
        end

        specify "4.99 is out of tolerance" do
          expect(subject.is_approximately?(4.99)).to be(false)
        end
      end
    end

    describe "<=>" do
      context "comparing a value greater than the input" do
        specify "just inside the precision value is 0" do
          expect(subject <=> 1.000001).to eq(0)
        end

        specify "just outside the precision value is -1" do
          expect(subject <=> 1.000002).to eq(-1)
        end
      end

      context "comparing a value less than the input" do
        specify "just inside the precision value is 0" do
          expect(subject <=> 0.999999).to eq(0)
        end

        specify "just outside the precision value is 1" do
          expect(subject <=> 0.999998).to eq(1)
        end
      end
    end

    describe "delta or precision-only constructors" do
      context "using only a delta" do
        subject { ApproximateValue.with_delta(1, 0.1) }

        specify "has delta 0.1" do
          expect(subject.delta).to eq(0.1)
        end

        specify "has precision 1" do
          expect(subject.precision).to eq(1)
        end

        specify "non-power-of-10 delta produces a precision that makes sense" do
          expect(ApproximateValue.with_delta(1, 0.56).precision).to eq(2)
        end

        specify ">= 1 delta produces a precision of 0 decimal places" do
          expect(ApproximateValue.with_delta(1, 10).precision).to eq(0)
        end

        specify "sanity value for largest precision is okay for large > 1 numbers with decimals" do
          expect(ApproximateValue.with_delta(1, 100000.56).precision).to eq(2)
        end
      end

      context "using only a precision" do
        subject { ApproximateValue.with_precision(1, 1) }

        specify "has delta 0.1" do
          expect(subject.delta).to eq(0.1)
        end

        specify "has precision 1" do
          expect(subject.precision).to eq(1)
        end

        specify "larger precisions produce the correct delta" do
          expect(ApproximateValue.with_precision(1, 6).delta).to eq(0.000001)
        end
      end
    end
  end
end
