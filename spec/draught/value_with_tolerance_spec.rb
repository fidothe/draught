require 'draught/value_with_tolerance'
require 'draught/tolerance'

module Draught
  RSpec.describe ValueWithTolerance do
    let(:tolerance) { Tolerance.new(0.000001) }
    subject { ValueWithTolerance.new(1, tolerance) }

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

    describe "==" do
      context "comparing a value greater than the input" do
        specify "just inside the precision value is ==" do
          expect(subject).to eq(1.000001)
        end

        specify "just outside the precision value is not ==" do
          expect(subject).to_not eq(1.000002)
        end
      end

      context "comparing a value less than the input" do
        specify "just inside the precision value is 0" do
          expect(subject).to eq(0.999999)
        end

        specify "just outside the precision value is 1" do
          expect(subject).to_not eq(0.999998)
        end
      end
    end

    describe "greater/less than" do
      context "checking greater-than" do
        specify "when significantly greater than the other reports > is true" do
          expect(subject > 0.999).to be(true)
        end

        specify "when greater than the value, but within tolerance, reports > is false" do
          expect(subject > 0.999999).to be(false)
        end
      end

      context "checking less-than" do
        specify "when significantly less than the other reports < is true" do
          expect(subject < 1.001).to be(true)
        end

        specify "when less than the value, but within tolerance, reports < is false" do
          expect(subject < 1.0000001).to be(false)
        end
      end

      context "checking greater-than-or-equal" do
        specify "when significantly greater than the other reports >= is true" do
          expect(subject >= 0.999).to be(true)
        end

        specify "a value greater than the subject, but within tolerance, reports >= is true" do
          expect(subject >= 1.0000001).to be(true)
        end
      end

      context "checking less-than-or-equal" do
        specify "when significantly less than the other reports <= is true" do
          expect(subject <= 1.001).to be(true)
        end

        specify "a value less than the subject, but within tolerance, reports <= is false" do
          expect(subject <= 0.999999).to be(true)
        end
      end
    end

    describe "to_f" do
      specify "returns the value, as a Float" do
        expect(subject.to_f).to be_a(Float)
        expect(subject.to_f).to eq(1.0)
      end
    end
  end
end
