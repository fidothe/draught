require 'draught/renderer'
require 'draught/vector'
require 'draught/point'
require 'draught/sheet'
require 'draught/bounding_box'
require 'draught/arc_builder'

class TestRenderer
  attr_reader :paths, :reference_paths, :margin

  def initialize(opts = {})
    @paths = opts.fetch(:paths)
    @reference_paths = opts.fetch(:reference_paths, [])
    @margin = opts.fetch(:margin, 24)
    @overlay = opts.fetch(:overlay, true)
  end

  def render(name)
    Draught::Renderer.render_to_file(sheet, "#{name}.pdf")
  end

  def sheet
    Draught::Sheet.new(width: width, height: height, lower_left: Draught::Point.new(20,20), containers: [bbox])
  end

  def width
    @width ||= untranslated_bbox.width + margin
  end

  def height
    @height ||= untranslated_bbox.height + margin
  end

  def bbox
    @bbox ||= untranslated_bbox.translate(Draught::Vector.translation_between(untranslated_bbox.centre, sheet_centre))
  end

  def untranslated_bbox
    @untranslated_bbox ||= Draught::BoundingBox.new(*containers)
  end

  def sheet_centre
    Draught::Point.new(width/2, height/2)
  end

  def containers
    @containers ||= paths.map { |path|
      paths_to_render = [path]
      if overlay?
        paths_to_render.concat(order_overlay(path, increments: 0.5, min_radius: 2))
      end
      Draught::BoundingBox.new(*paths_to_render)
    } + reference_paths
  end

  def overlay?
    @overlay
  end

  def order_overlay(path, opts = {})
    increments = opts.fetch(:increments, 1)
    min_radius = opts.fetch(:min_radius,  5)
    overlay_paths = path.points.each_with_index.flat_map { |point, i|
      circle_paths = (i + 1).times.map { |n|
        radius = min_radius + increments * (n - 1)
        path = Draught::ArcBuilder.degrees(angle: 360, radius: radius).path
        translation = Draught::Vector.translation_between(Draught::Point.new(-radius, 0), point)
        path.translate(translation)
      }
    }
  end
end
