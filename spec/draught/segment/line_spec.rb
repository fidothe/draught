require 'draught/world'
require 'draught/extent_examples'
require 'draught/pathlike_examples'
require 'draught/boxlike_examples'
require 'draught/segment/line'
require 'draught/parser/svg'

module Draught::Segment
  RSpec.describe Line do
    let(:world) { Draught::World.new }
    let(:metadata) { Draught::Metadata::Instance.new(name: 'name') }

    def p(x,y)
      world.point.new(x,y)
    end

    describe "manipulating line_segments" do
      let(:radians) { deg_to_rad(45) }
      let(:length) { 10 }
      subject { Line.build(world, length: length, radians: radians) }

      context "shortening makes a new line_segment" do
        it "by moving the end point in" do
          expected = Line.build(world, length: 8, radians: radians)

          expect(subject.extend(by: -2, at: :end)).to eq(expected)
        end

        it "by moving the start point out" do
          line_segment = Line.build(world, length: 8, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.end_point, subject.end_point))

          expect(subject.extend(by: -2, at: :start)).to eq(expected)
        end
      end

      context "lengthening makes a new line_segment" do
        it "by moving the end point out" do
          expected = Line.build(world, length: 12, radians: radians)

          expect(subject.extend(by: 2, at: :end)).to eq(expected)
        end

        it "by moving the start point out" do
          line_segment = Line.build(world, length: 12, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.end_point, subject.end_point))

          expect(subject.extend(by: 2, at: :start)).to eq(expected)
        end
      end

      it "defaults to moving the end point" do
        expected = Line.build(world, length: 12, radians: radians)

        expect(subject.extend(by: 2)).to eq(expected)
      end

      context "altering length by specifying explicitly" do
        it "by moving the end point" do
          expected = Line.build(world, length: 20, radians: radians)

          expect(subject.extend(to: 20, at: :end)).to eq(expected)
        end

        it "by moving the start point out" do
          line_segment = Line.build(world, length: 5, radians: radians)
          expected = line_segment.translate(world.vector.translation_between(line_segment.end_point, subject.end_point))

          expect(subject.extend(to: 5, at: :start)).to eq(expected)
        end
      end

      describe "splitting a line segment by t value produces correctly sized pairs of lines" do
        let(:input) { Line.build(world, length: 8, radians: 0) }
        let(:split) { input.split(t) }
        let(:pre) { split[0] }
        let(:post) { split[1] }

        context "at t=0.25" do
          let(:t) { 0.25 }

          specify { expect(pre.length).to eq(2) }
          specify { expect(pre.start_point).to eq(input.start_point) }
          specify { expect(post.length).to eq(6) }
          specify { expect(post.end_point).to eq(input.end_point) }
        end

        context "at t=0.5" do
          let(:t) { 0.5 }

          specify { expect(pre.length).to eq(4) }
          specify { expect(pre.start_point).to eq(input.start_point) }
          specify { expect(post.length).to eq(4) }
          specify { expect(post.end_point).to eq(input.end_point) }
        end

        context "at t=0.75" do
          let(:t) { 0.75 }

          specify { expect(pre.length).to eq(6) }
          specify { expect(pre.start_point).to eq(input.start_point) }
          specify { expect(post.length).to eq(2) }
          specify { expect(post.end_point).to eq(input.end_point) }
        end
      end

      specify "returns itself if #line is called" do
        expect(subject.line).to be(subject)
      end

      context "preservation of metadata" do
        subject { Line.build(world, length: length, radians: radians, metadata: metadata) }

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
    end

    describe "computing and projecting points on the line" do
      subject { Line.build(world, start_point: p(0,0), end_point: p(10,10)) }

      specify "computing a point on the line with t in the range 0..1" do
        expect(subject.compute_point(0.8)).to eq(p(8,8))
      end

      specify "projecting a point already on the line onto it" do
        expect(subject.project_point(subject.compute_point(0.8))).to eq(0.8)
      end

      specify "projecting a point not on the line but perpendicular to the line onto it" do
        expect(subject.project_point(p(10,0))).to eq(0.5)
      end
    end

    specify "can return their center point along the line" do
      # A 3-4-5 triangle hypotenuse
      l = Line.build(world, start_point: p(100,100), end_point: p(500,400))
      expect(l.center).to eq(p(300,250))
    end

    describe "[] access" do
      subject { Line.build(world, end_point: world.point.new(2,2)) }

      it "returns a Path when [Range]-style access is used" do
        expect(subject[0..0]).to eq(world.path.new(points: [subject.first]))
      end

      it "returns a Path when [start, length]-style access is used" do
        expect(subject[0,1]).to eq(world.path.new(points: [subject.first]))
      end
    end

    specify "can return a Path copy of itself" do
      line = Line.build(world, end_point: world.point.new(2,2))
      expect(line.to_path).to eq(world.path.simple(points: line.points))
    end

    it_should_behave_like "a pathlike thing" do
      subject { described_class.build(world, end_point: end_point) }
      let(:points) { subject.points }
      let(:end_point) { world.point.new(4,4) }
    end

    it_should_behave_like "it has an extent" do
      subject { described_class.build(world, end_point: upper_right) }
      let(:lower_left) { world.point.zero }
      let(:upper_right) { world.point(1,2) }
    end

    it_should_behave_like "a basic rectangular box-like thing" do
      subject { Line.build(world, end_point: world.point.new(4,4)) }
    end

    describe "pretty printing" do
      specify "a generates its pathlike start-point plus end-point" do
        line = Line.build(world, end_point: world.point.new(5,0))
        expect(line).to pp_as("(Pl 0,0 5,0)\n")
      end
    end

    describe "extend angle bugs", :svg_fixture do
      let(:tolerance) { Draught::Tolerance.new(0.001) } # Affinity Designer rounds to 3 d.p., so for the fixture comparisons to work, so do we.

      svg_fixture('line-segment-extension.svg') {
        fetch_grouped(input: /a-([0-9]+)$/, expected: /a-([0-9]+)-extended$/)
        map_paths { |world, path| world.line_segment.from_path(path) }
      }.each do |world, angle, input, expected|
        specify "extending a #{angle}º line" do
          actual = input.extend(by: 100)

          expect(actual.end_point).to approximate(expected.end_point).tolerance(tolerance)
          expect(actual.radians).to be_within(0.00001).of(input.radians)
          expect(actual.radians).to be_within(0.00001).of(expected.radians)
        end
      end
    end
  end
end
