require 'draught/corner_builder'
require 'draught/world'
require 'draught/arc_builder'
require 'draught/segment/line'

module Draught
  RSpec.describe CornerBuilder do
    let(:tolerance) { Tolerance.new(0.000001) }
    # let(:world) { World.new(tolerance) }
    let(:world) { World.new }
    subject { described_class.new(world) }
    let(:arc_builder) { ArcBuilder.new(world) }

    describe "joing two paths with a rounded corner returns a new path containing the incoming path up to the point the arc starts, the arc, and the rest of the outgoing path" do
      context "the two paths meet at right-angles" do
        let(:horizontal) { world.line_segment.horizontal(100) }
        let(:up) { world.line_segment.vertical(100) }
        let(:down) { world.line_segment.vertical(-100) }

        specify "when the incoming line_segment is left-right and the outgoing line_segment is bottom-to-top" do
          expected = world.path.build {
            points world.point.zero
            points world.arc.degrees(angle: 90, radius: 10, starting_angle: 270).path.translate(world.vector(90,0))
            points world.point(100,100)
          }

          joined = subject.join_rounded(horizontal, up, radius: 10)

          expect(joined).to eq(expected)
        end

        specify "when the incoming line_segment is left-right and the outgoing line_segment is top-to-bottom" do
          expected = world.path.build {
            points world.point.zero
            points world.arc.degrees(angle: -90, radius: 10, starting_angle: -90).path.translate(world.vector(90,0))
            points world.point(100,-100)
          }

          joined = subject.join_rounded(horizontal, down, radius: 10)

          expect(joined).to eq(expected)
        end

        specify "when the incoming line_segment is at a 45º angle top-left - bottom-right" do
          plus_45 = deg_to_rad(45)
          minus_45 = deg_to_rad(-45)
          expected = world.path.build {
            points world.line_segment(radians: minus_45, length: 90)
            points world.arc.degrees(angle: 90, radius: 10, starting_angle: -135).path.
              translate(world.vector.translation_between(world.point.zero, last_point)).subpaths.first.points[1..-1]
            points world.line_segment(radians: plus_45, length: 90).
              translate(world.vector.translation_between(world.point.zero, last_point)).points[1]
          }

          incoming = world.line_segment(radians: minus_45, length: 100)
          outgoing = world.line_segment(radians: plus_45, length: 100)
          joined = subject.join_rounded(incoming, outgoing, radius: 10)

          expect(joined).to eq(expected)
        end

        context "handling Metadata" do
          let(:metadata) { Metadata::Instance.new(name: 'name') }
          let(:styled_horizontal) { horizontal.with_metadata(metadata) }

          context "when the first path has metadata but the builder does not" do
            let(:joined) { subject.join_rounded(styled_horizontal, up, radius: 10) }

            specify "the resulting path has a blank metadata" do
              expect(joined.metadata).to_not be(metadata)
            end
          end

          context "when the builder specifies Metadata" do
            let(:joined) { subject.join_rounded(horizontal, up, radius: 10, metadata: metadata) }

            specify "the resulting path has the correct Metadata" do
              expect(joined.metadata).to be(metadata)
            end
          end
        end
      end

      context "the two paths meet at an acute angle" do
        specify "when the incoming line_segment is left-right and the outgoing line_segment is 45º from bottom-right to top-left" do
          arc = arc_builder.degrees(angle: 135, radius: 10, starting_angle: -90).path

          expected = world.path.build {
            points world.point.zero, arc.translate(world.vector(75.857864,0))
            points world.line_segment(radians: deg_to_rad(135), length: 100).translate(world.vector(100,0)).points[1]
          }
          h = world.line_segment.horizontal(100)
          l45 = world.line_segment(radians: deg_to_rad(135), length: 100)
          joined = subject.join_rounded(h, l45, radius: 10)

          expect(joined).to eq(expected)
        end

        specify "when the incoming line_segment is right-left and the outgoing line_segment is 45º from bottom-left to top-right" do
          arc = arc_builder.degrees(angle: -135, radius: 10, starting_angle: -270).path
          expected = world.path.build {
            points world.point.zero, arc.translate(world.vector(-75.857864,0))
            points world.line_segment(radians: deg_to_rad(45), length: 100).translate(world.vector(-100,0)).points[1]
          }

          h = world.line_segment.horizontal(-100)
          l45 = world.line_segment(radians: deg_to_rad(45), length: 100)
          joined = subject.join_rounded(h, l45, radius: 10)

          expect(joined).to eq(expected)
        end
      end

      context "the two paths meet at an obtuse angle" do
        specify "when the incoming line_segment is left-right and the outgoing line_segment is 135º from bottom-left to top-right" do
          arc = arc_builder.degrees(angle: 45, radius: 10, starting_angle: -90).path
          expected = world.path.build {
            points world.point.zero, arc.translate(world.vector.new(95.857864,0))
            points world.line_segment(radians: deg_to_rad(45), length: 100).translate(world.vector.new(100,0)).points[1]
          }

          h = world.line_segment.horizontal(100)
          l135 = world.line_segment.build(radians: deg_to_rad(45), length: 100)
          joined = subject.join_rounded(h, l135, radius: 10)

          expect(joined).to eq(expected)
        end

        specify "when the incoming line_segment is right-left and the outgoing line_segment is 135º from bottom-right to top-left" do
          arc = arc_builder.degrees(angle: -45, radius: 10, starting_angle: 90).path
          expected = world.path.build {
            points world.point.zero
            points arc.translate(world.vector.new(-95.857864,0))
            points world.line_segment(radians: deg_to_rad(135), length: 100).translate(world.vector(-100,0)).points[1]
          }

          h = world.line_segment.horizontal(-100)
          l135 = world.line_segment(radians: deg_to_rad(135), length: 100)
          joined = subject.join_rounded(h, l135, radius: 10)

          expect(joined).to eq(expected)
        end
      end
    end

    describe "joining multiple paths" do
      let(:horizontal) { world.line_segment.horizontal(100) }
      let(:up) { world.line_segment.vertical(100) }
      let(:down) { world.line_segment.vertical(-100) }

      specify "when asked to connect three paths" do
        expected = world.path.build {
          points world.point.zero
          points world.arc.degrees(angle: 90, radius: 10, starting_angle: 180).path.translate(world.vector.new(0,-90))
          points world.arc.degrees(angle: 90, radius: 10, starting_angle: 270).path.translate(world.vector.new(90,-100))
          points world.point.new(100,0)
        }

        # joined = world.path.connect(down, horizontal, up)
        joined = subject.join_rounded(down, horizontal, up, radius: 10)

        expect(joined).to eq(expected)
      end
    end
  end
end
