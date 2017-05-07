require_relative './vector'
require_relative './pointlike'
require 'matrix'

module Draught
  class Point
    def self.from_matrix(matrix)
      x, y = matrix.to_a.flatten
      Point.new(x, y)
    end

    include Pointlike

    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def point_type
      :point
    end

    def ==(other)
      other.point_type == point_type &&
        other.x == x && other.y == y
    end

    def approximates?(other, delta)
      other.point_type == point_type &&
        ((other.x - x).abs <= delta) &&
        ((other.y - y).abs <= delta)
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
