require_relative './pointlike'

module Draught
  # An abstract representation of a curve in a pointlike fashion, in the way
  # a CubicBezier is pointlike
  class Curve
    include Pointlike

    attr_reader :point
    protected :point

    def initialize(args = {})
      @point = args.fetch(:point)
      @cubic_beziers = args.fetch(:cubic_beziers).dup.freeze
    end

    def x
      @point.x
    end

    def y
      @point.y
    end

    def point_type
      :curve
    end

    def as_cubic_beziers
      @cubic_beziers
    end

    def ==(other)
      other.point_type == point_type && other.point == point &&
        other.as_cubic_beziers == as_cubic_beziers
    end

    def approximates?(other, delta)
      other.point_type == point_type &&
        point.approximates?(other.point, delta) &&
        as_cubic_beziers.zip(other.as_cubic_beziers).all? { |a, b|
          a.approximates?(b, delta)
        }
    end

    def translate(vector)
      self.class.new({
        point: @point.translate(vector),
        cubic_beziers: @cubic_beziers.map { |c| c.translate(vector) }
      })
    end

    def transform(transformer)
      self.class.new({
        point: @point.transform(transformer),
        cubic_beziers: @cubic_beziers.map { |c| c.transform(transformer) }
      })
    end
  end
end
