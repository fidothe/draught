require 'draught/approximately'

module Draught
  RSpec.describe Approximately do
    subject { Approximately.new(1) }

    it "is approximately 1.000001" do
      expect(subject.is_approximately?(1.000001)).to be(true)
    end

    it "is not approximately 1.00001" do
      expect(subject.is_approximately?(1.00001)).to_not be(true)
    end

    it "offers a convenience class method for one-off comparisons" do
      expect(Approximately.equal?(1, 1.000001))
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
  end
end
