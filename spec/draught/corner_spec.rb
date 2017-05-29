require 'draught/corner'
require 'draught/arc_builder'
require 'draught/line'
require 'draught/path_builder'

module Draught
  RSpec.describe Corner do
    describe "joing two paths with a rounded corner returns a new containing the incoming path up to the point the arc starts, the arc, and the rest of the outgoing path" do
      context "the two paths meet at right-angles" do
        def deg_to_rad(degrees)
          degrees * (Math::PI/180)
        end

        let(:horizontal) { Line.horizontal(100) }
        let(:up) { Line.vertical(100) }
        let(:down) { Line.vertical(-100) }

        specify "when the incoming line is left-right and the outgoing line is bottom-to-top" do
          expected = PathBuilder.build { |p|
            p << Point::ZERO << Point.new(90,0)
            p << ArcBuilder.degrees(angle: 90, radius: 10, starting_angle: 270).curve.translate(Vector.new(90,0))
            p << Point.new(100,100)
          }

          joined = Corner.join_rounded(radius: 10, paths: [horizontal, up])

          expect(joined).to approximate(expected).within(0.00001)
        end

        specify "when the incoming line is left-right and the outgoing line is top-to-bottom" do
          expected = PathBuilder.build { |p|
            p << Point::ZERO << Point.new(90,0)
            p << ArcBuilder.degrees(angle: -90, radius: 10, starting_angle: -90).curve.translate(Vector.new(90,0))
            p << Point.new(100,-100)
          }

          joined = Corner.join_rounded(radius: 10, paths: [horizontal, down])

          expect(joined).to approximate(expected).within(0.00001)
        end

        specify "when the incoming line is at a 45º angle top-left - bottom-right" do
          expected = PathBuilder.build { |p|
            p << Line.build(radians: deg_to_rad(-45), length: 90)
            p << ArcBuilder.degrees(angle: 90, radius: 10, starting_angle: -135).curve.
              translate(Vector.translation_between(Point::ZERO, p.last))
            p << Line.build(radians: deg_to_rad(45), length: 90).
              translate(Vector.translation_between(Point::ZERO, p.last))[1]
          }

          incoming = Line.build(radians: deg_to_rad(-45), length: 100)
          outgoing = Line.build(radians: deg_to_rad(45), length: 100)
          joined = Corner.join_rounded(radius: 10, paths: [incoming, outgoing])

          expect(joined).to approximate(expected).within(0.00001)
        end
      end

      context "the two paths meet at an acute angle" do
        def deg_to_rad(degrees)
          degrees * (Math::PI/180)
        end

        specify "when the incoming line is left-right and the outgoing line is 45º from bottom-right to top-left" do
          arc = ArcBuilder.degrees(angle: 135, radius: 10, starting_angle: -90).path
          expected = PathBuilder.build { |p|
            p << Point::ZERO << arc.translate(Vector.new(75.857864,0))
            p << Line.build(radians: deg_to_rad(135), length: 100).translate(Vector.new(100,0))[1]
          }

          h = Line.horizontal(100)
          l45 = Line.build(radians: deg_to_rad(135), length: 100)
          joined = Corner.join_rounded(radius: 10, paths: [h, l45])

          expect(joined).to approximate(expected).within(0.00001)
        end

        specify "when the incoming line is right-left and the outgoing line is 45º from bottom-left to top-right" do
          arc = ArcBuilder.degrees(angle: -135, radius: 10, starting_angle: -270).path
          expected = PathBuilder.build { |p|
            p << Point::ZERO << arc.translate(Vector.new(-75.857864,0))
            p << Line.build(radians: deg_to_rad(45), length: 100).translate(Vector.new(-100,0))[1]
          }

          h = Line.horizontal(-100)
          l45 = Line.build(radians: deg_to_rad(45), length: 100)
          joined = Corner.join_rounded(radius: 10, paths: [h, l45])

          expect(joined).to approximate(expected).within(0.00001)
        end
      end

      context "the two paths meet at an obtuse angle" do
        def deg_to_rad(degrees)
          degrees * (Math::PI/180)
        end

        specify "when the incoming line is left-right and the outgoing line is 135º from bottom-left to top-right" do
          arc = ArcBuilder.degrees(angle: 45, radius: 10, starting_angle: -90).path
          expected = PathBuilder.build { |p|
            p << Point::ZERO << arc.translate(Vector.new(95.857864,0))
            p << Line.build(radians: deg_to_rad(45), length: 100).translate(Vector.new(100,0))[1]
          }

          h = Line.horizontal(100)
          l135 = Line.build(radians: deg_to_rad(45), length: 100)
          joined = Corner.join_rounded(radius: 10, paths: [h, l135])

          expect(joined).to approximate(expected).within(0.00001)
        end

        specify "when the incoming line is right-left and the outgoing line is 135º from bottom-right to top-left" do
          arc = ArcBuilder.degrees(angle: -45, radius: 10, starting_angle: 90).path
          expected = PathBuilder.build { |p|
            p << Point::ZERO << arc.translate(Vector.new(-95.857864,0))
            p << Line.build(radians: deg_to_rad(135), length: 100).translate(Vector.new(-100,0))[1]
          }

          h = Line.horizontal(-100)
          l135 = Line.build(radians: deg_to_rad(135), length: 100)
          joined = Corner.join_rounded(radius: 10, paths: [h, l135])

          expect(joined).to approximate(expected).within(0.00001)
        end
      end
    end

    describe "joining multiple paths", focus: true do
      let(:horizontal) { Line.horizontal(100) }
      let(:up) { Line.vertical(100) }
      let(:down) { Line.vertical(-100) }

      specify "when asked to connect three paths" do
        expected = PathBuilder.build { |p|
          p << Point::ZERO << Point.new(0,-90)
          p << ArcBuilder.degrees(angle: 90, radius: 10, starting_angle: 180).curve.translate(Vector.new(0,-90))
          p << Point.new(90,-100)
          p << ArcBuilder.degrees(angle: 90, radius: 10, starting_angle: 270).curve.translate(Vector.new(90,-100))
          p << Point.new(100,0)
        }

        ref = PathBuilder.connect(down, horizontal, up)
        joined = Corner.join_rounded(radius: 10, paths: [down, horizontal, up])

        expect(joined).to approximate(expected).within(0.00001)
      end
    end
  end
end
