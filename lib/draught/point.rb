module Draught
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def points
      [self]
    end

    def ==(other)
      other.x == x && other.y == y
    end

    def translate(point)
      Point.new(x + point.x, y + point.y)
    end

    def difference(point)
      Point.new(point.x - x, point.y - y)
    end

    def transform(transformer)
      Point.new(*transformer.call(x, y))
    end

    ZERO = new(0, 0)
  end
end
