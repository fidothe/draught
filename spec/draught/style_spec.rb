require 'draught/style'

module Draught
  RSpec.describe Style do
    let(:args) { {stroke_color: 'black', stroke_width: '1pt', fill: 'none'} }
    subject { described_class.new(**args) }

    context "instances" do
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

    describe "equality comparison" do
      specify "instances with the same attributes compare equal" do
        other = described_class.new(**args)

        expect(subject).to eq(other)
      end

      specify "instances with differing attributes do not compare equal" do
        other = described_class.new(**args.merge(fill: 'hot pink'))

        expect(subject).to_not eq(other)
      end
    end
  end
end
