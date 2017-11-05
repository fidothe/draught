require 'draught/approximately'

module Draught
  RSpec.describe Approximately do
    it "offers a convenience class method for one-off comparisons" do
      expect(Approximately.equal?(1, 1.000001)).to be(true)
    end

    it "allows a delta to be set" do
      expect(Approximately.equal?(1, 1.000001, 0.0000001)).to be(false)
    end
  end
end
