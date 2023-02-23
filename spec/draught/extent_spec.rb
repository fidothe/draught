require 'draught/world'
require 'draught/extent'

RSpec.shared_examples "an extent" do
  specify "should have the correct width" do
    expect(subject.width).to eq(width)
  end

  specify "should have the correct height" do
    expect(subject.height).to eq(height)
  end

  specify "should have the correct x-max" do
    expect(subject.x_max).to eq(x_max)
  end

  specify "should have the correct y-max" do
    expect(subject.y_max).to eq(y_max)
  end

  specify "should have the correct x-min" do
    expect(subject.x_min).to eq(x_min)
  end

  specify "should have the correct y-min" do
    expect(subject.y_min).to eq(y_min)
  end

  specify "should have the correct lower-left point" do
    expect(subject.lower_left).to eq(world.point(x_min, y_min))
  end

  specify "should have the correct upper-left point" do
    expect(subject.upper_left).to eq(world.point(x_min, y_max))
  end

  specify "should have the correct lower-right point" do
    expect(subject.lower_right).to eq(world.point(x_max, y_min))
  end

  specify "should have the correct upper-right point" do
    expect(subject.upper_right).to eq(world.point(x_max, y_max))
  end
end

module Draught
  RSpec.describe Extent do
    let(:world) { World.new }
    let(:point) { world.point(1,1) }
    let(:other_point) { world.point(2,2) }

    context "an empty Extent" do
      subject { described_class.new(world, items: []) }

      let(:x_min) { 0 }
      let(:x_max) { 0 }
      let(:y_min) { 0 }
      let(:y_max) { 0 }
      let(:width) { 0 }
      let(:height) { 0 }

      it_should_behave_like "an extent"
    end

    context "containing an array of Points" do
      subject { described_class.new(world, items: [point, other_point]) }

      let(:x_min) { 1 }
      let(:x_max) { 2 }
      let(:y_min) { 1 }
      let(:y_max) { 2 }
      let(:width) { 1 }
      let(:height) { 1 }

      it_should_behave_like "an extent"
    end

    context "Using custom mappers for an array of things containing points" do
      let(:p3) { world.point(3,3) }
      let(:p4) { world.point(-3,-3) }

      subject { described_class.new(
        world,
        items: [[point, other_point], [p3,p4]],
        x_mapper: ->(points) { points.map(&:x) },
        y_mapper: ->(points) { points.map(&:y) },
      ) }

      let(:x_min) { -3 }
      let(:x_max) { 3 }
      let(:y_min) { -3 }
      let(:y_max) { 3 }
      let(:width) { 6 }
      let(:height) { 6 }

      it_should_behave_like "an extent"
    end

    context "Using the PATHLIKE_*_MAPPER mappers for an array of extents" do
      let(:p3) { world.point(3,3) }
      let(:p4) { world.point(-3,-3) }

      let(:extent_1) { described_class.new(world, items: [point, other_point]) }
      let(:extent_2) { described_class.new(world, items: [p3,p4]) }

      subject { described_class.from_pathlike(world, items: [extent_1, extent_2]) }

      let(:x_min) { -3 }
      let(:x_max) { 3 }
      let(:y_min) { -3 }
      let(:y_max) { 3 }
      let(:width) { 6 }
      let(:height) { 6 }

      it_should_behave_like "an extent"
    end
  end
end
