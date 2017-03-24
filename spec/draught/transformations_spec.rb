require 'draught/transformations'

module Draught
  RSpec.describe Transformations do
    describe "units" do
      it "can convert mm to Postscript pts" do
        expect(Transformations.mm_to_pt.call(1, 1)).to eq([
          2.8346456692913,
          2.8346456692913
        ])
      end
    end
  end
end
