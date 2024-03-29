require 'draught/segment/line/builder'
require 'draught/world'

module Draught::Segment
  RSpec.describe Line::Builder do
    let(:world) { Draught::World.new }
    let(:metadata) { Draught::Metadata::Instance.new(name: 'name') }

    subject { described_class.new(world) }

    describe "building a Line between two Points" do
      let(:finish) { world.point(4,4) }
      let(:line_segment) { subject.build(end_point: finish, metadata: metadata) }

      it "knows how long it is" do
        expect(line_segment.length).to be_within(0.01).of(5.66)
      end

      it "knows what angle (in radians) it's at" do
        expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(45))
      end

      specify "has a segment_type if :line" do
        expect(line_segment.segment_type).to eq(:line)
      end

      it "knows it's a line" do
        expect(line_segment.line?).to be(true)
      end

      it "knows it's not a curve" do
        expect(line_segment.curve?).to be(false)
      end

      specify "passes Metadata in correctly" do
        expect(line_segment.metadata).to be(metadata)
      end

      specify "a Line at 0º should have radians == 0" do
        line_segment = subject.build(end_point: world.point(10,0))

        expect(line_segment.radians).to be_within(0.0001).of(0)
      end

      context "angles < 90º" do
        it "copes with a Line of angle ~89.9º" do
          line_segment = subject.build(end_point: world.point(0.007,4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(89.9))
        end

        it "copes with a Line of angle 60º" do
          line_segment = subject.build(end_point: world.point(2.31,4))

          expect(line_segment.length).to be_within(0.01).of(4.62)
          expect(line_segment.radians).to be_within(0.001).of(deg_to_rad(60))
        end

        it "copes with a Line of angle 45º" do
          line_segment = subject.build(end_point: world.point(4,4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(45))
        end

        it "copes with a Line of angle 30º" do
          line_segment = subject.build(end_point: world.point(4,2.31))

          expect(line_segment.length).to be_within(0.01).of(4.62)
          expect(line_segment.radians).to be_within(0.001).of(deg_to_rad(30))
        end

        it "copes with a Line of angle ~1º" do
          line_segment = subject.build(end_point: world.point(4,0.0699))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(1))
        end
      end

      context "angles >= 90º" do
        it "copes with a Line of angle 90º" do
          line_segment = subject.build(end_point: world.point(0,4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(90))
        end

        it "copes with a Line of angle < 180º" do
          line_segment = subject.build(end_point: world.point(-4,4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(135))
        end

        it "copes with a Line of angle 180º" do
          line_segment = subject.build(end_point: world.point(-4,0))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(180))
        end

        it "copes with a Line of angle < 270º" do
          line_segment = subject.build(end_point: world.point(-4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(225))
        end

        it "copes with a Line of angle 270º" do
          line_segment = subject.build(end_point: world.point(0,-4))

          expect(line_segment.length).to be_within(0.01).of(4)
          expect(line_segment.radians).to eq(deg_to_rad(270))
        end

        it "copes with a Line of angle < 360º" do
          line_segment = subject.build(end_point: world.point(4,-4))

          expect(line_segment.length).to be_within(0.01).of(5.66)
          expect(line_segment.radians).to be_within(0.0001).of(deg_to_rad(315))
        end
      end
    end

    describe "generating horizontal Line objects" do
      specify "a line_segment of width N is like a Path with points at (0,0) and (N,0)" do
        expected = world.path.build { points p(0,0), p(10, 0) }

        expect(subject.horizontal(10).to_path).to eq(expected)
      end

      specify "metadata can be passed too" do
        line_segment = subject.horizontal(10, metadata: metadata)

        expect(line_segment.metadata).to be(metadata)
      end
    end

    describe "generating vertical Line objects" do
      specify "a line_segment of height N is like a Path with points at (0,0) and (0,N)" do
        expected = world.path.build { points p(0,0), p(0, 10) }

        expect(subject.vertical(10).to_path).to eq(expected)
      end

      specify "metadata can be passed too" do
        line_segment = subject.vertical(10, metadata: metadata)

        expect(line_segment.metadata).to be(metadata)
      end
    end

    describe "generating Line objects of a given length and angle", :svg_fixture do
      let(:tolerance) { Draught::Tolerance.new(0.001) } # Affinity Designer only goes to 3 d.p.
      let(:world) { Draught::World.new(tolerance) }

      def deg_to_rad(degrees)
        degrees = degrees.is_a?(String) ? Integer(degrees, 10) : degrees
        degrees * (Math::PI / 180)
      end

      svg_fixture('line-segment-extension.svg') {
        fetch_grouped(expected: /a-([0-9]+)$/)
        map_paths { |world, path| world.line_segment.from_path(path) }
      }.each do |world, angle, expected|
        specify "correctly builds a line of angle #{angle}º" do
          expect(subject.build(length: 100, radians: deg_to_rad(angle)).to_path).to eq(expected)
        end
      end

      context "ludicrous angles" do
        let(:length) { 5.656854 }

        it "treats a 360º angle as 0º" do
          expected = subject.build(end_point: world.point(length, 0))

          expect(subject.build(length: length, radians: deg_to_rad(360))).to eq(expected)
        end

        it "treats a > 360º angle properly" do
          expected = subject.build(end_point: world.point(-4,4))

          expect(subject.build(length: length, radians: deg_to_rad(495))).to eq(expected)
        end

        it "treats a > 360º right-angle properly" do
          expected = subject.build(end_point: world.point(0,length))

          expect(subject.build(length: length, radians: deg_to_rad(450))).to eq(expected)
        end

        it "treats a > 720º angle properly" do
          expected = subject.build(end_point: world.point(4,-4))

          expect(subject.build(length: length, radians: deg_to_rad(1035))).to eq(expected)
        end

        it "treats a > 720º right-angle properly" do
          expected = subject.build(end_point: world.point(0,-length))

          expect(subject.build(length: length, radians: deg_to_rad(630))).to eq(expected)
        end
      end

      context "handling Metadata" do
        let(:line_segment) {
          subject.build(length: 50, radians: deg_to_rad(45),
            metadata: metadata)
        }

        specify "passes Metadata in correctly" do
          expect(line_segment.metadata).to be(metadata)
        end
      end
    end

    describe "generating Line objects that don't start at 0,0" do
      it "can generate a Line from points" do
        line_segment = subject.build(start_point: world.point(1,1), end_point: world.point(5,5))

        expect(line_segment.radians).to be_within(0.00001).of(Math::PI/4)
        expect(line_segment.length).to be_within(0.01).of(5.66)
      end

      it "can generate a Line from angle/length and start point" do
        line_segment = subject.build(start_point: world.point(1,1), radians: Math::PI/4, length: 5.656854)

        expect(line_segment.to_path).to eq(world.path.build { points p(1,1), p(5,5) })
      end
    end

    describe "when passed non-Point Pointlikes" do
      let(:start_point) { world.point(0,0) }
      let(:end_point) { world.point(10,0) }
      let(:expected) { subject.build(start_point: start_point, end_point: end_point) }
      let(:cubic_start) {
        world.cubic_bezier(end_point: start_point, control_point_1: world.point(1,0), control_point_2: world.point(0,1))
      }
      let(:cubic_end) {
        world.cubic_bezier(end_point: end_point, control_point_1: world.point(11,0), control_point_2: world.point(10,1))
      }

      specify "if handed a CubicBezier at the start, use its position point" do
        expect(subject.build(start_point: cubic_start, end_point: end_point)).to eq(expected)
      end

      specify "if handed a CubicBezier at the end, use its position point" do
        expect(subject.build(start_point: start_point, end_point: cubic_end)).to eq(expected)
      end
    end

    describe "building a Line from a two-item Path" do
      context "given a Path" do
        it "generates the Line correctly" do
          line = subject.build(start_point: world.point.zero, end_point: world.point(4,4))

          expect(subject.from_path(line.to_path)).to eq(line)
        end

        it "blows up for a > 2-point Path" do
          path = world.path.simple(world.point.zero, world.point(4,4), world.point(6,6))

          expect {
            subject.from_path(path)
          }.to raise_error(ArgumentError)
        end

        it "blows up for a < 2-point Path" do
          path = world.path.simple(world.point.zero)

          expect {
            subject.from_path(path)
          }.to raise_error(ArgumentError)
        end

        specify "the path's metadata is taken" do
          path = world.path.simple(world.point.zero, world.point(4,4), metadata: metadata)
          line_segment = subject.from_path(path)

          expect(line_segment.metadata).to be(metadata)
        end

        specify "metadata can be passed in" do
          path = world.path.simple(world.point.zero, world.point(4,4))
          line_segment = subject.from_path(path, metadata: metadata)

          expect(line_segment.metadata).to be(metadata)
        end
      end
    end

    describe "building a Line from two points" do
      let(:p1) { world.point.zero }
      let(:p2) { world.point(4,4) }

      it "generates the Line correctly" do
        expect(subject.from_to(p1, p2)).to eq(subject.build(start_point: p1, end_point: p2))
      end

      specify "metadata can be passed too" do
        line_segment = subject.from_to(p1, p2, metadata: metadata)

        expect(line_segment.metadata).to be(metadata)
      end
    end
  end
end
