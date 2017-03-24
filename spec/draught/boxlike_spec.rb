require 'draught/boxlike_examples'
require 'draught/boxlike'
require 'draught/spec_box'

module Draught
  RSpec.describe Boxlike do
    subject { SpecBox.new({
      lower_left: Point.new(10,10),
      width: 20, height: 10
    }) }

    it_should_behave_like "a basic rectangular box-like thing"

    context "interaction with other geometric objects" do
     context "working out if a Point is included within this Boxlike" do
      let(:in_point) { Point.new(15,15) }
        let(:out_point) { Point.new(15,25) }
        let(:edge_point) { Point.new(10,15) }

        specify "an included Point is reported included" do
          expect(subject.include_point?(in_point)).to be true
        end

        specify "an excluded Point is reported excluded" do
          expect(subject.include_point?(out_point)).to be false
        end

        specify "Points on one or more edges are considered included" do
          expect(subject.include_point?(edge_point)).to be true
        end
      end

      context "working out if another Boxlike overlaps with this box" do
        context "boxes overlap when" do
          specify "a box is entirely contained within this box" do
            other = SpecBox.new({lower_left: Point.new(11,11), width: 5, height: 5})
            expect(subject.overlaps?(other)).to be true
          end

          specify "a box entirely contains this box" do
            other = SpecBox.new({lower_left: Point::ZERO, width: 50, height: 50})
            expect(subject.overlaps?(other)).to be true
          end

          specify "a box partially overlaps this box" do
            other = SpecBox.new({lower_left: Point.new(5,5), width: 10, height: 10})
            expect(subject.overlaps?(other)).to be true
          end

          specify "a box is exactly the same size, with the same origin" do
            expect(subject.overlaps?(subject)).to be true
          end
        end

        context "boxes do not overlap when" do
          def other(x, y)
            other = SpecBox.new({lower_left: Point.new(x, y), width: 10, height: 10})
          end

          subject { SpecBox.new({
            lower_left: Point.new(10,10),
            width: 20, height: 10
          }) }

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
        end
      end
    end
  end
end
