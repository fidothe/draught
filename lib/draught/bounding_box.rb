require_relative 'boxlike'
require_relative 'point'

module Draught
  class BoundingBox
    include Boxlike

    attr_reader :world, :paths

    def initialize(world, *paths)
      @world = world
      @paths = paths
    end

    def width
      x_max - x_min
    end

    def height
      y_max - y_min
    end

    def lower_left
      @lower_left ||= world.point.new(x_min, y_min)
    end

    def translate(point)
      self.class.new(world, *paths.map { |path| path.translate(point) })
    end

    def transform(transformer)
      self.class.new(world, *paths.map { |path| path.transform(transformer) })
    end

    def zero_origin
      move_to(world.point.zero)
    end

    def ==(other)
      paths == other.paths
    end

    def containers
      []
    end

    def box_type
      [:container]
    end

    private

    def x_max
      @x_max ||= upper_rights.map(&:x).max
    end

    def x_min
      @x_min ||= lower_lefts.map(&:x).min
    end

    def y_max
      @y_max ||= upper_rights.map(&:y).max
    end

    def y_min
      @y_min ||= lower_lefts.map(&:y).min
    end

    def lower_lefts
      @lower_lefts ||= paths.map(&:lower_left)
    end

    def upper_rights
      @upper_rights ||= paths.map(&:upper_right)
    end
  end
end
