require 'prawn'

module Draught
  class Renderer
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
        first_point = points.shift
        close_and_stroke do
          self.line_width = 0.003
          move_to first_point.x, first_point.y
          points.each do |point|
            case point
            when Draught::CubicBezier
              curve_to([point.end_point.x, point.end_point.y], {
                bounds: [
                  [point.control_point_1.x, point.control_point_1.y],
                  [point.control_point_2.x, point.control_point_2.y]
                ]
              })
            else
              line_to point.x, point.y
            end
          end
          line_to first_point.x, first_point.y
        end
      end
    end

    def self.render_to_file(sheet, path)
      new(sheet).render_to_file(path)
    end

    attr_reader :sheet

    def initialize(sheet)
      @sheet = sheet
    end

    def context
      @context ||= PdfContext.new(sheet.width, sheet.height)
    end

    def render_to_file(path)
      render && context.save_as(path)
    end

    def render
      sheet.containers.each do |container|
        walk(container)
      end
    end

    def render_container(container, context)
    end

    def render_path(path, context)
      context.draw_closed_path(path)
    end

    private

    def walk(container)
      render_container(container, context)
      render_paths(container.paths, context)
      container.containers.each do |container|
        walk(container)
      end
    end

    def render_paths(paths, context)
      paths.each do |path|
        render_path(path, context)
      end
    end
  end
end
