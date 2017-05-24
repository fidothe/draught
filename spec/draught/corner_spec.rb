require 'draught/corner'
require 'draught/arc_builder'
require 'draught/line'
require 'draught/path_builder'
require 'draught/renderer'
require 'draught/sheet'
require 'draught/bounding_box'

module Draught
  RSpec.describe Corner do
    def order_overlay(path, opts = {})
      increments = opts.fetch(:increments, 1)
      min_radius = opts.fetch(:min_radius,  5)
      overlay_paths = path.points.each_with_index.flat_map { |point, i|
        puts "POINT: #{point.inspect}"
        puts "i: #{i}"
        circle_paths = (i + 1).times.map { |n|
          radius = min_radius + increments * (n - 1)
          path = ArcBuilder.degrees(angle: 360, radius: radius).path
          translation = Vector.translation_between(Point.new(-radius, 0), point)
          path.translate(translation)
        }
      }
    end

    def render(opts = {})
      name = opts.fetch(:name)
      paths = opts.fetch(:paths)
      reference_paths = opts.fetch(:reference_paths)

      containers = paths.map { |path|
        BoundingBox.new(path, *order_overlay(path, increments: 0.5, min_radius: 2))
      } + reference_paths

      bbox = BoundingBox.new(*containers)

      puts "BBOX: #{bbox.centre.inspect}"
      bbox = bbox.translate(Vector.translation_between(bbox.centre, Point.new(100,100)))
      puts "BBOX TRANSLATE: #{Vector.translation_between(bbox.centre, Point.new(100,100)).inspect}"
      sheet = Sheet.new(width: 200, height: 200, lower_left: Point.new(20,20), containers: [bbox])

      Renderer.render_to_file(sheet, "test-corner-#{name}.pdf")
    end

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

          joined = Corner::Rounded.join(radius: 10, paths: [horizontal, up])

          expect(joined).to approximate(expected).within(0.00001)
        end

        specify "when the incoming line is left-right and the outgoing line is top-to-bottom" do
          expected = PathBuilder.build { |p|
            p << Point::ZERO << Point.new(90,0)
            p << ArcBuilder.degrees(angle: -90, radius: 10, starting_angle: -90).curve.translate(Vector.new(90,0))
            p << Point.new(100,-100)
          }

          joined = Corner::Rounded.join(radius: 10, paths: [horizontal, down])

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
          joined = Corner::Rounded.join(radius: 10, paths: [incoming, outgoing])

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
          joined = Corner::Rounded.join(radius: 10, paths: [h, l45])

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
          joined = Corner::Rounded.join(radius: 10, paths: [h, l45])

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
          joined = Corner::Rounded.join(radius: 10, paths: [h, l135])

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
          joined = Corner::Rounded.join(radius: 10, paths: [h, l135])

          expect(joined).to approximate(expected).within(0.00001)
        end
      end
    end
  end
end
