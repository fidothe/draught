require 'forwardable'

module Draught
  # An Extent represents the rectangular bounds of a path or group of paths
  class Extent
    module InstanceMethods
      def self.included(base)
        base.extend Forwardable
        methods_to_delegate = Extent.public_instance_methods(false) - [:world, :items, :x_mapper, :y_mapper]
        base.def_delegators(:extent, *methods_to_delegate)
      end

      def extent
        raise NotImplementedError, "classes including Exent::InstanceMethods must define #extent and return an extent"
      end
    end

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

    # @return [Point] the point
    def lower_left
      @lower_left ||= world.point(x_min, y_min)
    end

    # @return [Point] the point
    def upper_left
      @upper_left ||= world.point(x_min, y_max)
    end

    # @return [Point] the point
    def lower_right
      @lower_right ||= world.point(x_max, y_min)
    end

    # @return [Point] the point
    def upper_right
      @upper_right ||= world.point(x_max, y_max)
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
  end
end
