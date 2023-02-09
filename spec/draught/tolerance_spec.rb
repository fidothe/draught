require 'draught/tolerance'

module Draught
  RSpec.describe Tolerance do
    subject { Tolerance.new(0.000001) }

    context "a tolerance of 0.000001" do
      specify "a precision of 6 decimal places" do
        expect(subject.precision).to eq(6)
      end

      specify "a delta of 0.000001" do
        expect(subject.delta).to eq(0.000001)
      end

      it "knows that 1.000001 is within tolerance" do
        expect(subject.within?(1, 1.000001)).to be(true)
        expect(subject.outside?(1, 1.000001)).to be(false)
      end

      it "knows that 1.00001 is outside tolerance" do
        expect(subject.within?(1, 1.00001)).to be(false)
        expect(subject.outside?(1, 1.00001)).to be(true)
      end
    end

    it "allows a different delta to be set" do
      subject = Tolerance.new(0.0000001)
      expect(subject.within?(1, 1.000001)).to be(false)
    end

    it "allows a different delta and precision (in decimal places) to be set" do
      subject = Tolerance.new(0.0000001, 7)
      expect(subject.within?(1, 1.000001)).to be(false)
    end

    context "deltas and precisions that don't line up" do
      context "10 plus-or-minus 5, to 2 d.p." do
        subject { Tolerance.new(5, 2) }

        specify "15.001 is in tolerance" do
          expect(subject.within?(10, 15.001)).to be(true)
        end

        specify "15.01 is out of tolerance" do
          expect(subject.within?(10, 15.01)).to be(false)
        end

        specify "4.999 is in tolerance" do
          expect(subject.within?(10, 4.999)).to be(true)
        end

        specify "4.99 is out of tolerance" do
          expect(subject.within?(10, 4.99)).to be(false)
        end
      end
    end

    describe "<=>" do
      subject {
        ValueWithTolerance.new(1, Tolerance.new(0.000001))
      }

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
        subject { Tolerance.with_delta(0.1) }

        specify "has delta 0.1" do
          expect(subject.delta).to eq(0.1)
        end

        specify "has precision 1" do
          expect(subject.precision).to eq(1)
        end

        specify "non-power-of-10 delta produces a precision that makes sense" do
          expect(Tolerance.with_delta(0.56).precision).to eq(2)
        end

        specify ">= 1 delta produces a precision of 0 decimal places" do
          expect(Tolerance.with_delta(10).precision).to eq(0)
        end

        specify "sanity value for largest precision is okay for large > 1 numbers with decimals" do
          expect(Tolerance.with_delta(100000.56).precision).to eq(2)
        end
      end

      context "using only a precision" do
        subject { Tolerance.with_precision(1) }

        specify "has delta 0.1" do
          expect(subject.delta).to eq(0.1)
        end

        specify "has precision 1" do
          expect(subject.precision).to eq(1)
        end

        specify "larger precisions produce the correct delta" do
          expect(Tolerance.with_precision(6).delta).to eq(0.000001)
        end
      end
    end
  end
end
