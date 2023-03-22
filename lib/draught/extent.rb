require 'forwardable'
require_relative 'value_with_tolerance'

module Draught
  # An Extent represents the rectangular bounds of a path or group of paths
  module Extent
    def self.included(base)
      base.extend Forwardable
      methods_to_delegate = Extent::Instance.public_instance_methods(false) - [:world, :items, :x_mapper, :y_mapper]
      base.def_delegators(:extent, *methods_to_delegate)
    end

    def extent
      raise NotImplementedError, "classes including Exent::InstanceMethods must define #extent and return an extent"
    end

    class Instance
      POINT_X_MAPPER = ->(point) { point.x }
      POINT_Y_MAPPER = ->(point) { point.y }
      PATHLIKE_X_MAPPER = ->(pathlike) { [pathlike.upper_left.x, pathlike.upper_right.x] }
      PATHLIKE_Y_MAPPER = ->(pathlike) { [pathlike.lower_left.y, pathlike.upper_left.y] }

      # @param world [Draught::World] the World
      # @param items [Enumerable] the items in this Extent
      # @return [Extent] an extent covering all the component Extents
      def self.from_pathlike(world, items:)
        new(world, items: items, x_mapper: PATHLIKE_X_MAPPER, y_mapper: PATHLIKE_Y_MAPPER)
      end

      # @!attribute [r] items
      #  @return [Enumerable] the items (points, other extents) contained in this extent
      # @!attribute [r] world
      #  @return [World] the World
      # @!attribute [r] x_mapper
      #   @return [Proc] a mapper between items and x-coords
      # @!attribute [r] y_mapper
      #   @return [Proc] a mapper between items and y-coords
      attr_reader :world, :items, :x_mapper, :y_mapper

      # @param world [Draught::World] the World
      # @param items [Enumerable] the items in this Extent
      # @param x_mapper [Proc] the mapper between this Extent's items and X values
      # @param y_mapper [Proc] the mapper between this Extent's items and Y values
      def initialize(world, items:, x_mapper: POINT_X_MAPPER, y_mapper: POINT_Y_MAPPER)
        @world, @items, @x_mapper, @y_mapper = world, items, x_mapper, y_mapper
      end

      # @return [Number] the width of the extent
      def width
        @width = x_max - x_min
      end

      # @return [Number] the height of the extent
      def height
        @height = y_max - y_min
      end

      # @return [Number] the max X value of the extent
      def x_max
        @x_max || (set_min_max; @x_max)
      end

      # @return [Number] the min X value of the extent
      def x_min
        @x_min || (set_min_max; @x_min)
      end

      # @return [Number] the max Y value of the extent
      def y_max
        @y_max ||= (set_min_max; @y_max)
      end

      # @return [Number] the min Y value of the extent
      def y_min
        @y_min ||= (set_min_max; @y_min)
      end

      # @return [ValueWithTolerance] the x_min value, with tolerance
      def x_min_value
        @x_min_value ||= ValueWithTolerance.new(x_min, world.tolerance)
      end

      # @return [ValueWithTolerance] the x_max value, with tolerance
      def x_max_value
        @x_max_value ||= ValueWithTolerance.new(x_max, world.tolerance)
      end

      # @return [ValueWithTolerance] the y_min value, with tolerance
      def y_min_value
        @y_min_value ||= ValueWithTolerance.new(y_min, world.tolerance)
      end

      # @return [ValueWithTolerance] the y_max value, with tolerance
      def y_max_value
        @y_max_value ||= ValueWithTolerance.new(y_max, world.tolerance)
      end

      # The point lower-left point of the extent
      #
      # @return [Point] the point
      def lower_left
        @lower_left ||= world.point(x_min, y_min)
      end

      # The point upper-left point of the extent
      #
      # @return [Point] the point
      def upper_left
        @upper_left ||= world.point(x_min, y_max)
      end

      # The point lower-right point of the extent
      #
      # @return [Point] the point
      def lower_right
        @lower_right ||= world.point(x_max, y_min)
      end

      # The point upper-left point of the extent
      #
      # @return [Point] the point
      def upper_right
        @upper_right ||= world.point(x_max, y_max)
      end

      # The point half-way down the extent on the left edge
      #
      # @return [Point] the point
      def centre_left
        @centre_left ||= world.point(x_min, y_min + height/2.0)
      end

      # The point half-way across the extent on the bottom edge
      #
      # @return [Point] the point
      def lower_centre
        @lower_centre ||= world.point(x_min + width/2.0, y_min)
      end

      # The point half-way down the extent on the right edge
      #
      # @return [Point] the point
      def centre_right
        @centre_right ||= world.point(x_max, y_min + height/2.0)
      end

      # The point half-way across the extent on the top edge
      #
      # @return [Point] the point
      def upper_centre
        @upper_centre ||= world.point(x_min + width/2.0, y_max)
      end

      # The point half-way across and half-way down the extent
      #
      # @return [Point] the point
      def centre
        @centre ||= world.point(x_min + width/2.0, y_min + height/2.0)
      end

      # Return the extent's corners anti-clockwise from the lower-left.
      #
      # @return [Array<Point>] the corner points
      def corners
        [lower_left, lower_right, upper_right, upper_left]
      end

      def left_edge
        @left_edge ||= world.line_segment.from_to(lower_left, upper_left)
      end

      def right_edge
        @right_edge ||= world.line_segment.from_to(lower_right, upper_right)
      end

      def top_edge
        @top_edge ||= world.line_segment.from_to(upper_left, upper_right)
      end

      def bottom_edge
        @bottom_edge ||= world.line_segment.from_to(lower_left, lower_right)
      end

      def edges
        [left_edge, right_edge, top_edge, bottom_edge]
      end

      # Reports if this Extent overlaps another.
      #
      # @param other [Extent::Instance] the other extent
      # @return [Boolean] true if the extents overlap
      def overlaps?(other)
        !disjoint?(other)
      end

      # Reports if this Extent entirely contains another.
      #
      # @param other [Extent::Instance] the other extent
      # @return [Boolean] true if the other extent is contained within this one
      def contains?(other)
        other.corners.all? { |corner| includes_point?(corner) }
      end

      # Reports if this Extent is disjoint from (does not overlap) another.
      #
      # @param other [Extent::Instance] the other extent
      # @return [Boolean] true if the extents are disjoint
      def disjoint?(other)
        horizontally_disjoint?(other) || vertically_disjoint?(other)
      end

      # Reports if the passed Point is within the bounds of this Extent.
      #
      # @param other [Draught::Point] the other extent
      # @return [Boolean] true if the point is included in the extent
      def includes_point?(point)
        horizontal_extent.include?(point.x) && vertical_extent.include?(point.y)
      end

      private

      def sort_x_values
        items.flat_map(&x_mapper).sort
      end

      def sort_y_values
        items.flat_map(&y_mapper).sort
      end

      def set_min_max
        sorted_x_values = sort_x_values
        sorted_y_values = sort_y_values
        if sorted_x_values.empty?
          @x_min, @x_max, @y_min, @y_max = 0, 0, 0, 0
        else
          @x_min, @x_max = sorted_x_values.first, sorted_x_values.last
          @y_min, @y_max = sorted_y_values.first, sorted_y_values.last
        end
      end

      def horizontally_disjoint?(other)
        x_max_value <= other.x_min || x_min_value >= other.x_max
      end

      def vertically_disjoint?(other)
        y_max_value <= other.y_min || y_min_value >= other.y_max
      end

      def horizontal_extent
        @horizontal_extent ||= x_min..x_max
      end

      def vertical_extent
        @vertical_extent ||= y_min..y_max
      end
    end
  end
end