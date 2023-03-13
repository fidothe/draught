require 'draught/world'

module Draught
  RSpec.describe World do
    let(:tolerance) { Tolerance.new(0.000001) }
    subject { World.new(tolerance) }

    def p(x, y)
      subject.point(x, y)
    end

    context "creating a World" do
      specify "without args, a new World uses the default Tolerance" do
        world = World.new
        expect(world.tolerance).to be(Tolerance::DEFAULT)
      end

      specify "can have a tolerance passed in at creation time" do
        expect(subject.tolerance).to be(tolerance)
      end
    end

    describe "inspecting World" do
      specify "shows the tolerance but nothing else by default" do
        expect(subject.inspect).to match(/#<Draught::World:0x[0-9a-f]+ tolerance: delta=1.0e-06, precision=6>/)
      end

      specify "doesn't show the builders even when they've been cached in ivars" do
        p1 = subject.point(1,2)

        expect(subject.inspect).to match(/#<Draught::World:0x[0-9a-f]+ tolerance: delta=1.0e-06, precision=6>/)
      end
    end

    describe "creating things" do
      describe "Points" do
        specify "calling #point with args delegates to PointBuilder#build" do
          expect(subject.point(1,2)).to be_a(Point)
        end

        specify "provides a PointBuilder" do
          builder = subject.point
          expect(builder).to be_a(PointBuilder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Cubics" do
        let(:end_point) { subject.point(4,0) }
        let(:control_1) { subject.point(1,2) }
        let(:control_2) { subject.point(3,2) }

        specify "calling #cubic_bezier with args delegates to CubicBezierBuilder#build" do
          expect(subject.cubic_bezier(
            end_point: end_point,
            control_point_1: control_1,
            control_point_2: control_2)
          ).to be_a(CubicBezier)
        end

        specify "provides a CubicBezierBuilder" do
          builder = subject.cubic_bezier
          expect(builder).to be_a(CubicBezierBuilder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Vectors" do
        specify "calling #vector with args delegates to VectorBuilder#build" do
          expect(subject.vector(1,2)).to be_a(Vector)
        end

        specify "provides a VectorBuilder" do
          builder = subject.vector
          expect(builder).to be_a(VectorBuilder)
          expect(builder.world).to be(subject)
        end
      end

      specify "provides a Path Builder" do
        builder = subject.path
        expect(builder).to be_a(Path::Builder)
        expect(builder.world).to be(subject)
      end

      describe "Line Segments" do
        specify "calling #line_segment with args delegates to Segment::Line::Builder#build" do
          point = subject.point(1,2)
          expect(subject.line_segment(end_point: point)).to be_a(Segment::Line)
        end

        specify "provides a Segment::Line::Builder" do
          builder = subject.line_segment
          expect(builder).to be_a(Segment::Line::Builder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Line Segments" do
        specify "calling #line_segment with args delegates to Segment::Line::Builder#build" do
          point = subject.point(1,2)
          expect(subject.line_segment(end_point: point)).to be_a(Segment::Line)
        end

        specify "provides a Segment::Line::Builder" do
          builder = subject.line_segment
          expect(builder).to be_a(Segment::Line::Builder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Arcs" do
        specify "calling #arc with args delegates to ArcBuilder#build" do
          expect(subject.arc(radians: 1, radius: 10)).to be_a(Arc)
        end

        specify "provides an ArcBuilder" do
          builder = subject.arc
          expect(builder).to be_a(ArcBuilder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Circles" do
        specify "calling #circle with args delegates to CircleBuilder#build" do
          expect(subject.circle(radius: 10)).to be_a(Circle)
        end

        specify "provides a CircleBuilder" do
          builder = subject.circle
          expect(builder).to be_a(CircleBuilder)
          expect(builder.world).to be(subject)
        end
      end

      describe "Curve Segments" do
        specify "calling #curve_segment with args delegates to Segment::Curve::Builder#build" do
          expect(subject.curve_segment(
            start_point: p(0,0), end_point: p(1,1),
            control_point_1: p(0,1),
            control_point_2: p(1,1)
          )).to be_a(Segment::Curve)
        end

        specify "provides a Segment::Curve::Builder" do
          builder = subject.curve_segment
          expect(builder).to be_a(Segment::Curve::Builder)
          expect(builder.world).to be(subject)
        end
      end
    end
  end
end
