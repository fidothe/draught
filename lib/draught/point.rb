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
      self.class.new(x + point.x, y + point.y)
    end

    def translation_to(point)
      self.class.new(point.x - x, point.y - y)
    end

    def transform(transformer)
      self.class.new(*transformer.call(x, y))

    end

    ZERO = new(0, 0)
  end
end
