require 'draught/style'

module Draught
  RSpec.describe Style do
    context "instances" do
      let(:args) { {stroke_color: 'black', stroke_width: '1pt', fill: 'none'} }
      subject { described_class.new(args) }

      specify "report their stroke colour" do
        expect(subject.stroke_color).to eq('black')
      end

      specify "report their stroke width" do
        expect(subject.stroke_width).to eq('1pt')
      end

      specify "report their fill" do
        expect(subject.fill).to eq('none')
      end
    end
  end
end
