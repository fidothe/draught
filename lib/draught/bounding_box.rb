require_relative 'point'

module Draught
  class BoundingBox
    attr_reader :paths

    def initialize(*paths)
      @paths = paths
    end

    def width
      x_max - x_min
    end

    def height
      y_max - y_min
    end

    def translate(point)
      self.class.new(*paths.map { |path| path.translate(point) })
    end

    def zero_origin
      difference = lower_left.difference(Point::ZERO)
      return self if difference == Point::ZERO
      translate(difference)
    end

    def ==(other)
      paths == other.paths
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

    def lower_left
      @lower_left ||= Point.new(x_min, y_min)
    end

    def upper_right
      @upper_right ||= Point.new(x_max, y_max)
    end

    def lower_lefts
      @lower_lefts ||= paths.map(&:lower_left)
    end

    def upper_rights
      @upper_rights ||= paths.map(&:upper_right)
    end
  end
end
