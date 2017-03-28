require 'draught/sheet'
require 'draught/boxlike_examples'
require 'draught/spec_box'
require 'draught/point'

module Draught
  RSpec.describe Sheet do
    let(:box) { SpecBox.new(lower_left: Point.new(50,50), width: 200, height: 100) }
    let(:boxes) { [box] }
    subject { Sheet.new(boxes: boxes, width: 1000, height: 600) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "has its origin at 0,0 by default" do
      expect(subject.lower_left).to eq(Point::ZERO)
    end

    context "translation" do
      it "correctly translates its boxes" do
        translated = subject.translate(Point.new(100,100))
        expect(translated.boxes).to eq([box.translate(Point.new(100,100))])
      end
    end
  end
end
