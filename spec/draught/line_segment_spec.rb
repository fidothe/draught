require 'draught/world'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'
require 'draught/line_segment'

module Draught
  RSpec.describe LineSegment do
    let(:world) { World.new }
    let(:metadata) { Metadata::Instance.new(name: 'name') }

    def p(x,y)
      world.point.new(x,y)
    end

    describe "manipulating line_segments" do
      let(:radians) { deg_to_rad(45) }
      let(:length) { 10 }
      subject { LineSegment.build(world, length: length, radians: radians) }

      context "shortening makes a new line_segment" do
        it "by moving the end point in" do
          expected = LineSegment.build(world, length: 8, radians: radians)

          expect(subject.extend(by: -2, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(world, length: 8, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(by: -2, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      context "lengthening makes a new line_segment" do
        it "by moving the end point out" do
          expected = LineSegment.build(world, length: 12, radians: radians)

          expect(subject.extend(by: 2, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(world, length: 12, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(by: 2, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      it "defaults to moving the end point" do
        expected = LineSegment.build(world, length: 12, radians: radians)

        expect(subject.extend(by: 2)).to approximate(expected).within(0.00001)
      end

      context "altering length by specifying explicitly" do
        it "by moving the end point" do
          expected = LineSegment.build(world, length: 20, radians: radians)

          expect(subject.extend(to: 20, at: :end)).to approximate(expected).within(0.00001)
        end

        it "by moving the start point out" do
          line_segment = LineSegment.build(world, length: 5, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.last, subject.last))

          expect(subject.extend(to: 5, at: :start)).to approximate(expected).within(0.00001)
        end
      end

      context "preservation of metadata" do
        subject { LineSegment.build(world, length: length, radians: radians, metadata: metadata) }

        context "when adding at the start" do
          let(:extended) { subject.extend(by: 2, at: :start) }

          specify "metadata is preserved" do
            expect(extended.metadata).to be(metadata)
          end
        end

        context "when adding at the end" do
          let(:extended) { subject.extend(by: 2, at: :end) }

          specify "metadata is preserved" do
            expect(extended.metadata).to be(metadata)
          end
        end
      end

      context "computing a point on the line with t (0..1, like Bezier curves)" do
        it "by moving the end point" do
          expected = LineSegment.build(world, length: 8, radians: radians).end_point

          expect(subject.compute_point(0.8)).to approximate(expected).within(0.00001)
        end
      end
    end

    specify "can return their center point along the line" do
      # A 3-4-5 triangle hypotenuse
      l = LineSegment.build(world, start_point: p(100,100), end_point: p(500,400))
      expect(l.center).to eq(p(300,250))
    end

    describe "[] access" do
      subject { LineSegment.build(world, end_point: world.point.new(2,2)) }

      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(world.path.new(points: [world.point.zero]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[1,1]).to eq(world.path.new(points: [world.point.new(2,2)]))
      end
    end

    it_should_behave_like "a pathlike thing" do
      let(:end_point) { world.point.new(4,4) }
      let(:points) { [world.point.zero, end_point] }
      subject { LineSegment.build(world, end_point: end_point) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { LineSegment.build(world, end_point: world.point.new(4,4)) }
    end

    describe "pretty printing" do
      specify "a generates its pathlike start-point plus end-point" do
        line = LineSegment.build(world, end_point: world.point.new(5,0))
        expect(line).to pp_as("(Pl 0,0 5,0)\n")
      end
    end
  end
end
