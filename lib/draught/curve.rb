require_relative './pointlike'

module Draught
  # An abstract representation of a curve that can only be represented by
  # multiple Cubic Beziers (like an arc > 90º) in the same pointlike fashion, a
  # CubicBezier uses, which allows easy use in places a CubicBezier can be used
  # (like PDF/SVG path rendering)
  class Curve
    include Pointlike

    attr_reader :world, :end_point
    protected :end_point

    def initialize(world, args = {})
      @world = world
      @end_point = args.fetch(:end_point)
      @cubic_beziers = args.fetch(:cubic_beziers).dup.freeze
    end

    def x
      @end_point.x
    end

    def y
      @end_point.y
    end

    def point_type
      :curve
    end

    def as_cubic_beziers
      @cubic_beziers
    end

    def ==(other)
      other.point_type == point_type && other.end_point == end_point &&
        other.as_cubic_beziers == as_cubic_beziers
    end

    def approximates?(other, delta)
      other.point_type == point_type &&
        end_point.approximates?(other.end_point, delta) &&
        number_of_segments == other.number_of_segments &&
        as_cubic_beziers.zip(other.as_cubic_beziers).all? { |a, b|
          a.approximates?(b, delta)
        }
    end

    def number_of_segments
      @cubic_beziers.length
    end
    protected :number_of_segments

    def translate(vector)
      self.class.new(world, {
        end_point: @end_point.translate(vector),
        cubic_beziers: @cubic_beziers.map { |c| c.translate(vector) }
      })
    end

    def transform(transformer)
      self.class.new(world, {
        end_point: @end_point.transform(transformer),
        cubic_beziers: @cubic_beziers.map { |c| c.transform(transformer) }
      })
    end

    def pretty_print(q)
      q.group(1, '{', '}') do
        q.seplist(@cubic_beziers, ->() { q.breakable }) do |cubic|
          q.pp cubic
        end
      end
    end
  end
end
