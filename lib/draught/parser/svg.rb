require 'nokogiri'
require 'draught/bounding_box'
require 'draught/metadata'

module Draught
  module Parser
    # Parse the objects in an SVG document into Draught objects.
    #
    # This is currently primarily a tool to make certain kinds of unit testing
    # possible / explicable, so it's a bit toy for complex use.
    class SVG
      PARSE_MAP = {
        'g' => :box,
        'path' => :path
      }

      # @!attribute [r] world
      #   @return [Draught::World] the World in use
      attr_reader :io, :world
      private :io

      # @param io [IO] the IO object the SVG data can be read from
      # @param world [Draught::World] the World to use for object creation
      def initialize(world, io)
        @world, @io = world, io
      end

      # @return [Draught::Boxlike]
      def parse!
        box(svg_doc.root)
      end

      private

      def svg_doc
        @svg_doc ||= Nokogiri::XML(io)
      end

      def parse_children(children)
        result = []
        children.each do |child|
          child_result = dispatch(child)
          result << child_result unless child_result.nil?
        end
        result
      end

      def box(element)
        children = parse_children(element.children)
        Draught::BoundingBox.new(world, children)
      end

      def path(element)
        parsed_subpaths = parse_path_d(element['d'])
        parsed_metadata = parse_metadata(element)
        raise ArgumentError, "Cannot parse Paths containing Subpaths" if parsed_subpaths.length > 1

        world.path.build {
          metadata parsed_metadata
          points parsed_subpaths.first[:points]
          closed if parsed_subpaths.first[:closed]
        }
      end

      def dispatch(element)
        meth = PARSE_MAP[element.name]
        if meth
          send(meth, element)
        end
      end

      def parse_path_d(d_value)
        DParser.parse!(world, d_value)
      end

      def parse_metadata(element)
        args = {
          annotation: parse_class_attr(element),
          name: parse_id_attr(element)
        }.compact
        Draught::Metadata::Instance.new(**args)
      end

      def parse_class_attr(element)
        return nil unless element.has_attribute?('class')
        parse_class_value(element['class'])
      end

      def parse_class_value(attr_value)
        return nil if attr_value == ''
        attr_value.split(' ').compact
      end

      def parse_id_attr(element)
        return nil unless element.has_attribute?('id')
        element['id']
      end

      # Parse the d attr from a path
      class DParser
        D_TOKENIZER = /(?:([MLC])([0-9., -]+)|([Zz]))/
        POINTS_TOKENIZER = /(-?[0-9][0-9.]*),(-?[0-9][0-9.]*)/
        CMD_MAP = {
          'M' => :m,
          'm' => :m,
          'L' => :l,
          'l' => :l,
          'C' => :c,
          'c' => :c,
          'Z' => :z,
          'z' => :z
        }

        def self.parse!(world, d)
          new(world, d).parse!
        end

        attr_reader :world, :d, :subpaths

        def initialize(world, d)
          @world, @d = world, d
          @subpaths = []
        end

        def current_subpath
          subpaths.last
        end

        def current_subpath_points
          subpaths.last[:points]
        end

        def add_subpath!
          @subpaths << {points: []}
        end

        def parse!
          d.scan(D_TOKENIZER) { |cmd, points_str, closed|
            if !closed.nil?
              z
            else
              send(CMD_MAP[cmd], points_str)
            end
          }
          subpaths
        end

        # The M/m commands move to a point without drawing and start a Subpath
        def m(points_str)
          add_subpath!
          points_str.scan(POINTS_TOKENIZER) { |x, y|
            current_subpath_points << world.point.new(x.to_f, y.to_f)
          }
        end

        # L/l draw a line between two points
        def l(points_str)
          points_str.scan(POINTS_TOKENIZER) { |x, y|
            current_subpath_points << world.point.new(x.to_f, y.to_f)
          }
        end

        # C/c draw a cubic bezier curve
        def c(points_str)
          points = []
          points_str.scan(POINTS_TOKENIZER) { |x, y|
            points << world.point.new(x.to_f, y.to_f)
          }
          current_subpath_points << Draught::CubicBezier.new(world, control_point_1: points[0], control_point_2: points[1], end_point: points[2])
        end

        # Z/z closes the current Subpath
        def z
          current_subpath[:closed] = true
        end
      end
    end
  end
end