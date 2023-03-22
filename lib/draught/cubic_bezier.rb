require_relative './pointlike'

module Draught
  # Represents a simple Cubic Bezier curve in the way that PostScript/PDF and
  # SVG think about it - an end point plus the two control points, with the
  # curve beginning at whatever the previous point in a path was.
  #
  # To represent an entire Cubic Bezier curve standalone, you can use
  # {Segment::Curve}, which defers to this class when needed.
  class CubicBezier
    include Pointlike

    attr_reader :world, :end_point, :control_point_1, :control_point_2

    def initialize(world, args = {})
      @world = world
      @end_point = args.fetch(:end_point)
      @control_point_1 = args.fetch(:control_point_1)
      @control_point_2 = args.fetch(:control_point_2)
    end

    def x
      end_point.x
    end

    def y
      end_point.y
    end

    # The position to use when checking to see if the start/end path points of a
    # path are duplicated when the path is closed. For a CubicBezier, this is
    # its end_point.
    #
    # @return [Point] the point
    def position_point
      end_point
    end

    def ==(other)
      other.point_type == point_type &&
        comparison_array(other).all? { |a, b| a == b }
    end

    def point_type
      :cubic_bezier
    end

    def approximates?(other, delta)
      other.point_type == point_type &&
        comparison_array(other).all? { |a, b|
          a.approximates?(b, delta)
        }
    end

    def translate(vector)
      transform(vector.to_transform)
    end

    def transform(transformer)
      new_args = Hash[args_hash.map { |k, point|
        [k, point.transform(transformer)]
      }]
      self.class.new(world, new_args)
    end

    def pretty_print(q)
      q.group(1, 'C', '') do
        q.seplist([control_point_1, control_point_2, end_point], ->() { }) do |pointish|
          q.breakable
          q.pp pointish
        end
      end
    end

    private

    def args_hash
      {end_point: end_point, control_point_1: control_point_1, control_point_2: control_point_2}
    end

    def comparison_array(other)
      args_hash.map { |arg, point|
        [other.send(arg), point]
      }
    end
  end
end
