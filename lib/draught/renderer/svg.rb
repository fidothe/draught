require 'stringio'
require 'pathname'

module Draught
  module Renderer
    class SVG
      class Builder
        attr_reader :out

        def initialize(out = nil)
          @out = out.nil? ? StringIO.new : out
        end

        def root(&block)
          out << %{<?xml version="1.0" encoding="UTF-8" standalone="no"?>}
          element('svg', version: '1.1', xmlns: 'http://www.w3.org/2000/svg', &block)
        end

        def empty_element(name, attr_hash={})
          out << "<#{name}"
          attrs(attr_hash)
          out << "/>"
        end

        def element(name, attr_hash={})
          out << "<#{name}"
          attrs(attr_hash)
          out << ">"
          yield(self) if block_given?
          out << "</#{name}>"
        end

        def attrs(attr_hash)
          attr_hash.each do |name, value|
            attr(name, value)
          end
        end

        def attr(name, value)
          out << %{ #{name}="#{value}"}
        end
      end

      XY = ->(p) { "#{p.x},#{p.y}" }

      def self.render_to_file(path, paths)
        path = Pathname.new(path)
        path.open('w:utf-8') do |f|
          new(f).doc(paths)
        end
      end

      def self.render_to_string(paths)
        out = StringIO.new
        new(out).doc(paths)
        out.string
      end

      attr_reader :builder

      def initialize(out)
        @builder = Builder.new(out)
      end

      def doc(objects)
        builder.root do |doc|
          draw_objects(objects)
        end
      end

      def draw_objects(objects)
        objects.each do |object|
          draw_object(object)
        end
      end

      def draw_object(object)
        case object.box_type
        when [:container]
          g(object.paths)
        else
          path(object)
        end
      end

      def g(objects = [])
        builder.element('g') do |builder|
          draw_objects(objects)
        end
      end

      def path(pathlike)
        first = pathlike.points[0]
        rest = pathlike.points[1..-1]
        path_def = rest.chunk_while { |before, after|
          before.class === after
        }.flat_map(&method(:render_pointlike_chunks)).join(" ")
        builder.empty_element('path', d: "M #{XY.call(first)} " + path_def)
      end

      def render_pointlike_chunks(pointlikes)
        case pointlikes.first
        when Draught::Point
          ["L", pointlikes.map(&XY)]
        when Draught::Curve
          pointlikes.map { |curve| render_pointlike_chunks(curve.as_cubic_beziers) }
        when Draught::CubicBezier
          pointlikes.map { |cubic|
            ["C", [cubic.control_point_1, cubic.control_point_2, cubic.end_point].map(&XY)]
          }
        end
      end

      def out
        builder.out
      end
    end
  end
end