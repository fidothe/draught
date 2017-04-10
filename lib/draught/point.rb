require 'matrix'

module Draught
  class Point
    def self.from_matrix(matrix)
      x, y = matrix.to_a.flatten
      Point.new(x, y)
    end

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

    def to_matrix
      @matrix ||= Matrix[[x],[y],[1]].freeze
    end

    def transform(transformation_matrix)
      result = transformation_matrix * to_matrix
      new_x, new_y = result.to_a.flatten
      self.class.new(new_x, new_y)
    end

    ZERO = new(0, 0)
  end
end
