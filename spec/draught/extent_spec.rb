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
  RSpec.describe Extent::Instance do
    let(:world) { World.new }
    let(:point) { world.point(1,1) }
    let(:other_point) { world.point(2,2) }

    describe "containing different kinds of items" do
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

    describe "instances" do
      subject { described_class.new(world, items: [world.point(10,10), world.point(30,20)]) }

      context "centre points of the box" do
        specify "centre-left" do
          expect(subject.centre_left).to eq(world.point.new(10, 15))
        end

        specify "lower-centre" do
          expect(subject.lower_centre).to eq(world.point.new(20, 10))
        end

        specify "centre-right" do
          expect(subject.centre_right).to eq(world.point.new(30, 15))
        end

        specify "upper-centre" do
          expect(subject.upper_centre).to eq(world.point.new(20, 20))
        end

        specify "centre" do
          expect(subject.centre).to eq(world.point.new(20, 15))
        end
      end

      describe "working out if a Point is included within itself" do
        let(:in_point) { world.point.new(15,15) }
        let(:out_point) { world.point.new(15,25) }
        let(:edge_point) { world.point.new(10,15) }

        specify "an included Point is reported included" do
          expect(subject.includes_point?(in_point)).to be true
        end

        specify "an excluded Point is reported excluded" do
          expect(subject.includes_point?(out_point)).to be false
        end

        specify "Points on one or more edges are considered included" do
          expect(subject.includes_point?(edge_point)).to be true
        end
      end

      context "min/max x and y values with tolerance" do
        let(:extent) { described_class.new(world, items: [world.point(10,10), world.point(30,20)]) }

        context "the x-min value" do
          subject { extent.x_min_value }

          specify { is_expected.to be_a(ValueWithTolerance) }
          specify { is_expected.to eq(extent.x_min) }
        end

        context "the x-max value" do
          subject { extent.x_max_value }

          specify { is_expected.to be_a(ValueWithTolerance) }
          specify { is_expected.to eq(extent.x_max) }
        end
        context "the y-min value" do
          subject { extent.y_min_value }

          specify { is_expected.to be_a(ValueWithTolerance) }
          specify { is_expected.to eq(extent.y_min) }
        end
        context "the y-max value" do
          subject { extent.y_max_value }

          specify { is_expected.to be_a(ValueWithTolerance) }
          specify { is_expected.to eq(extent.y_max) }
        end
      end

      describe "working out if it is overlapped by another Extent" do
        def other(x, y, width: 10, height: 10)
          described_class.new(world, items: [world.point.new(x, y), world.point(x + width, y + height)])
        end

        context "extents overlap when" do
          specify "a box is entirely contained within this box" do
            expect(subject.overlaps?(other(11, 11, width: 5, height: 5))).to be true
          end

          specify "a box entirely contains this box" do
            expect(subject.overlaps?(other(0, 0, width: 50, height: 50))).to be true
          end

          specify "a box partially overlaps this box" do
            expect(subject.overlaps?(other(5, 5))).to be true
          end

          specify "a box is exactly the same size, with the same origin" do
            expect(subject.overlaps?(subject)).to be true
          end
        end

        context "extents do not overlap when" do
          specify "they are totally disjoint" do
            expect(subject.overlaps?(other(100,100))).to be false
          end

          specify "a bottom edge has the same y as the other's top edge" do
            expect(subject.overlaps?(other(10,0))).to be false
          end

          specify "a top edge has the same y as the other's bottom edge" do
            expect(subject.overlaps?(other(10,20))).to be false
          end

          specify "a left edge has the same x as the other's right edge" do
            expect(subject.overlaps?(other(30,10))).to be false
          end

          specify "a right edge has the same x as the other's left edge" do
            expect(subject.overlaps?(other(0,10))).to be false
          end

          specify "top-left corner == the other's bottom-right corner" do
            expect(subject.overlaps?(other(0,20))).to be false
          end

          specify "bottom-right corner == the other's top-left corner" do
            expect(subject.overlaps?(other(30,00))).to be false
          end

          specify "bottom-left corner == the other's top-right corner" do
            expect(subject.overlaps?(other(0,0))).to be false
          end

          specify "top-right corner == the other's bottom-left corner" do
            expect(subject.overlaps?(other(30,20))).to be false
          end

          context "the Tolerance is respected" do
            let(:tolerance) { Draught::Tolerance.new(0.01) }
            let(:world) { World.new(tolerance) }

            specify "a bottom edge has the same y as the other's top edge" do
              expect(subject.overlaps?(other(10,0.01))).to be false
            end

            specify "a top edge has the same y as the other's bottom edge" do
              expect(subject.overlaps?(other(10,19.99))).to be false
            end

            specify "a left edge has the same x as the other's right edge" do
              expect(subject.overlaps?(other(29.99,10))).to be false
            end

            specify "a right edge has the same x as the other's left edge" do
              expect(subject.overlaps?(other(0.01,10))).to be false
            end
          end
        end
      end
    end
  end
end
