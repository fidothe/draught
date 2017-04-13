require_relative './vector'
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

    def translate(vector)
      transform(vector.to_transform)
    end

    def translation_to(point)
      Vector.translation_between(self, point)
    end

    def to_matrix
      @matrix ||= Matrix[[x],[y],[1]].freeze
    end

    def transform(transformation)
      transformation.call(self)
    end

    ZERO = new(0, 0)
  end
end
