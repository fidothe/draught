require 'draught/sheet_builder'
require 'draught/world'
require 'draught/spec_box'
require 'prawn'

module Draught
  RSpec.describe SheetBuilder do
    let(:world) { World.new }
    let(:wide_box) { SpecBox.zeroed(world, width: 300, height: 100, min_gap: 50) }
    let(:args) { {boxes: [wide_box], max_width: 1000, max_height: 600, outer_gap: 5} }
    subject { SheetBuilder.new(world, args) }

    context "comparison" do
      it "compares equal to another sheet builder with the same boxes and other args" do
        other = SheetBuilder.new(world, args)

        expect(subject).to eq(other)
      end

      it "doesn't compare equal if a detail is changed" do
        other = SheetBuilder.new(world, args.merge(outer_gap: 10))

        expect(subject).not_to eq(other)
      end
    end

    context "nesting a single box fills the sheet with as many instances as possible" do
      let(:sheet) { subject.sheet }

      specify "fills it with the correct number of containers" do
        expect(sheet.paths.size).to eq(8)
      end

      specify "the sheet is the minimum needed width" do
        expect(sheet.width).to eq(660)
      end

      specify "the sheet is the minimum needed height" do
        expect(sheet.height).to eq(560)
      end
    end
  end
end
