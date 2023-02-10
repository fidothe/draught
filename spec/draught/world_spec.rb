require 'draught/world'

module Draught
  RSpec.describe World do
    let(:tolerance) { Tolerance.new(0.000001) }
    subject { World.new(tolerance) }

    context "creating a World" do
      specify "without args, a new World uses the default Tolerance" do
        world = World.new
        expect(world.tolerance).to be(Tolerance::DEFAULT)
      end

      specify "can have a tolerance passed in at creation time" do
        expect(subject.tolerance).to be(tolerance)
      end
    end

    context "creating things" do
      specify "provides a PointBuilder" do
        builder = subject.point
        expect(builder).to be_a(PointBuilder)
        expect(builder.world).to be(subject)
      end

      specify "provides a VectorBuilder" do
        builder = subject.vector
        expect(builder).to be_a(VectorBuilder)
        expect(builder.world).to be(subject)
      end

      specify "provides a PathBuilder" do
        builder = subject.path
        expect(builder).to be_a(PathBuilder)
        expect(builder.world).to be(subject)
      end

      specify "provides a Builder for Line Segments" do
        builder = subject.line_segment
        expect(builder).to be_a(Segment::Line::Builder)
        expect(builder.world).to be(subject)
      end

      specify "provides an ArcBuilder" do
        builder = subject.arc
        expect(builder).to be_an(ArcBuilder)
        expect(builder.world).to be(subject)
      end

      specify "provides a CircleBuilder" do
        builder = subject.circle
        expect(builder).to be_an(CircleBuilder)
        expect(builder.world).to be(subject)
      end

      specify "provides a Builder for Curve Segments" do
        builder = subject.curve_segment
        expect(builder).to be_a(Segment::Curve::Builder)
        expect(builder.world).to be(subject)
      end
    end
  end
end
