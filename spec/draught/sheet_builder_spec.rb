require 'draught/sheet_builder'
require 'draught/spec_box'
require 'prawn'

module Draught
  RSpec.describe SheetBuilder do
    let(:wide_box) { SpecBox.zeroed(width: 300, height: 100, min_gap: 50) }

    context "nesting a single box fills the sheet with as many instances as possible" do
      subject {
        wb = wide_box
        SheetBuilder.build(max_width: 1000, max_height: 600, outer_gap: 5) {
          add wb
        }
      }

      specify "fills it with the correct number of containers" do
        expect(subject.paths.size).to eq(8)
      end

      specify "the sheet is the minimum needed width" do
        expect(subject.width).to eq(660)
      end

      specify "the sheet is the minimum needed height" do
        expect(subject.height).to eq(560)
      end
    end
  end
end
