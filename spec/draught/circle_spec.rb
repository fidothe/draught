require 'draught/circle'
require 'draught/world'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'

module Draught
  RSpec.describe Circle do
    let(:world) { World.new }
    let(:circle_radians) { deg_to_rad(360) }
    subject { Circle.new(world, radius: 100) }

    it "reports its radius" do
      expect(subject.radius).to eq(100)
    end

    it "reports its centre point" do
      expect(subject.center).to eq(world.point.new(100,100))
    end

    context "generated arc" do
      specify "a 360º arc of the correct radius can be returned" do
        expect(subject.arc.radians).to eq(circle_radians)
        expect(subject.arc.radius).to eq(subject.radius)
      end

      specify "leaves path generation to the arc" do
        expect(subject.path).to eq(subject.arc.path)
      end

      specify "the generated path is in the right place" do
        expect(subject.path.upper_left).to eq(subject.upper_left)
        expect(subject.path.width).to eq(subject.width)
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:points) { subject.path.points }
    end

    it_should_behave_like "a basic rectangular box-like thing"
  end
end
