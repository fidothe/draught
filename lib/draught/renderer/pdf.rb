require 'prawn'
require_relative '../curve'
require_relative '../cubic_bezier'

module Draught
  module Renderer
    class PDF
      class PdfContext
        include Prawn::View

        attr_reader :width, :height

        def initialize(width, height)
          @width, @height = width, height
        end

        def document
          @document ||= Prawn::Document.new(page_size: [width, height], margin: 0)
        end

        def draw_closed_path(path)
          points = path.points.dup
          close_and_stroke do
            self.line_width = 0.003
            move_to(*point_tuple(points.shift))
            points.each do |pointlike|
              draw_pointlike(pointlike)
            end
          end
        end

        def draw_pointlike(pointlike)
          case pointlike
          when Draught::Curve
            pointlike.as_cubic_beziers.each do |cubic_bezier|
              draw_pointlike(cubic_bezier)
            end
          when Draught::CubicBezier
            curve_to(point_tuple(pointlike.end_point), {
              bounds: [
                point_tuple(pointlike.control_point_1),
                point_tuple(pointlike.control_point_2)
              ]
            })
          else
            line_to(*point_tuple(pointlike))
          end
        end

        def point_tuple(point)
          [point.x, point.y]
        end
      end

      def self.render_to_file(sheet, path)
        new(sheet).render_to_file(path)
      end

      attr_reader :root_box

      def initialize(root_box)
        @root_box = root_box
      end

      def context
        @context ||= PdfContext.new(root_box.width, root_box.height)
      end

      def render_to_file(path)
        render && context.save_as(path)
      end

      def render
        walk(root_box)
      end

      def render_container(container, context)
      end

      def render_path(path, context)
        context.draw_closed_path(path)
      end

      private

      def walk(box)
        render_container(box, context) if box.box_type.include?(:container)
        box.paths.each do |child|
          render_path(child, context) if child.box_type.include?(:path)
          walk(child)
        end
      end
    end
  end
end
