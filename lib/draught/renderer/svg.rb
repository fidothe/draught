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

        # @param container [Draught::Boxlike] the root container
        def root(container, &block)
          out << %{<?xml version="1.0" encoding="UTF-8" standalone="no"?>}
          element('svg', width: container.upper_right.x, height: container.upper_right.y, version: '1.1', xmlns: 'http://www.w3.org/2000/svg', &block)
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

      def doc(container)
        builder.root(container) do |doc|
          draw_objects(container.paths)
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
        builder.empty_element('path', path_attrs(pathlike))
      end

      def render_pointlike_chunks(pointlikes)
        case pointlikes.first
        when Draught::Point
          ["L", pointlikes.map(&XY)]
        when Draught::CubicBezier
          pointlikes.map { |cubic|
            ["C", [cubic.control_point_1, cubic.control_point_2, cubic.end_point].map(&XY)]
          }
        end
      end

      def out
        builder.out
      end

      # @param pathlike [Draught::Pathlike] the pathlike to generate attributes for
      # @return [Hash<Symbol,String>] name, value hash of attributes for an element
      def path_attrs(pathlike)
        {
          d: path_def_value(pathlike),
          style: style_attr_value(pathlike.style),
          class: class_attr_value(pathlike.annotation),
          id: id_attr_value(pathlike.name)
        }.reject { |k, v| v == '' }
      end

      # @param pathlike [Draught::Pathlike] the pathlike to generate a def for
      def path_def_value(pathlike)
        pathlike.subpaths.flat_map { |subpath|
          first = subpath.points[0]
          rest = subpath.points[1..-1]
          path_def = rest.chunk_while { |before, after|
            before.class === after
          }.flat_map(&method(:render_pointlike_chunks))
          ["M", XY.call(first)] + path_def
        }.join(" ")
      end

      # @param style [Draught::Style] the style to generate CSS properties for
      # @return [String] a CSS rules string
      def style_attr_value(style)
        properties = []
        {stroke_color: 'stroke', stroke_width: 'stroke-width', fill: 'fill'}.map { |style_meth, css_prop|
          value = style.send(style_meth)
          value.nil? ? nil : "#{css_prop}: #{value};"
        }.compact.join(' ')
      end

      # @param annotation [Array<String>] the annotation to generate a class attr from
      # @return [String] the space-separated class attr value
      def class_attr_value(annotation)
        return '' if annotation.empty?
        annotation.join(' ')
      end

      # @param name [String] the name to generate an id attr from
      # @return [String] the id value
      def id_attr_value(name)
        return '' if name.nil?
        name
      end
    end
  end
end