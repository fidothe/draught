require 'draught/approximate_range'

module Draught
  RSpec.describe ApproximateRange do
    subject { ApproximateRange.new(1..2) }

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
end
