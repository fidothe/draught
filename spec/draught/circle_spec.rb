require 'draught/circle'
require 'draught/world'
require 'draught/extent_examples'
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
        expect(subject.to_path).to eq(subject.arc.to_path)
      end

      specify "the generated path is in the right place" do
        expect(subject.to_path.upper_left).to eq(subject.upper_left)
        expect(subject.to_path.width).to eq(subject.width)
      end
    end

    describe "closed/open paths" do
      subject { described_class.new(world, radius: 100) }

      specify "an Circle is closeable" do
        expect(subject.closeable?).to be(true)
      end

      specify "is not open" do
        expect(subject.open?).to be(false)
      end

      specify "is closed" do
        expect(subject.closed?).to be(true)
      end

      specify "calling closed returns itself" do
        expect(subject.closed).to be(subject)
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:points) { subject.points }
    end

    it_should_behave_like "it has an extent" do
      let(:lower_left) { world.point(0,0) }
      let(:upper_right) { world.point(200,200) }
    end

    it_should_behave_like "a basic rectangular box-like thing"
  end
end
