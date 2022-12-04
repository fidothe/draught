require 'draught/range_with_tolerance'
require 'draught/tolerance'

module Draught
  RSpec.describe RangeWithTolerance do
    let(:tolerance) { Tolerance.new(0.000001) }

    describe "creating a range with a tolerance" do
      subject { RangeWithTolerance.new(1..2, tolerance) }

      context "a tolerance of 0.000_001" do
        it "includes 2.000001" do
          expect(subject.include?(2.000001)).to be(true)
        end

        it "includes 0.999999" do
          expect(subject.include?(0.999999)).to be(true)
        end

        it "includes 1.5" do
          expect(subject.include?(1.5)).to be(true)
        end

        it "does not include 0.999998" do
          expect(subject.include?(0.999998)).to be(false)
        end

        it "does not inclued 2.000002" do
          expect(subject.include?(2.00002)).to be(false)
        end
      end

      context "a tolerance of 0.000_000_1" do
        let(:tolerance) { Tolerance.new(0.000_000_1) }

        it "does not include 2.000001 (2*10^-6)" do
          expect(subject.include?(2.000001)).to be(false)
        end

        it "does include 2.0000001 (2*10^-7)" do
          expect(subject.include?(2.0000001)).to be(true)
        end
      end
    end
  end
end
