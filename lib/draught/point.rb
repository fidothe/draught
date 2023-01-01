require_relative './pointlike'
require_relative './tolerance/x_y_comparable'
require_relative './vector'
require_relative './approximately'
require 'matrix'

module Draught
  class Point
    include Pointlike
    include Tolerance::XYComparable

    attr_reader :x, :y, :world, :tolerance

    def initialize(x, y, world)
      @x, @y, @world, @tolerance = x, y, world, world.tolerance
    end

    def point_type
      :point
    end

    def compare_compatible?(other)
      other.point_type == point_type
    end

    def approximates?(other, delta)
      other.point_type == point_type &&
        Approximately.equal?(other.x, x, delta) &&
        Approximately.equal?(other.y, y, delta)
    end

    def translate(vector)
      transform(vector.to_transform)
    end

    def translation_to(point)
      world.vector.translation_between(self, point)
    end

    # @return [Vector] a vector form of this point (Vector(self.x,self.y))
    def to_vector
      world.vector.new(x, y)
    end

    def to_matrix
      @matrix ||= Matrix[[x],[y],[1]].freeze
    end

    def transform(transformation)
      transformation.call(self, world)
    end

    def pretty_print(q)
      q.group(1, '', '') do
        q.text "#{x},#{y}"
      end
    end
  end
end
