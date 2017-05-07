require_relative './pointlike'

module Draught
  class CubicBezier
    include Pointlike

    attr_reader :end_point, :control_point_1, :control_point_2

    def initialize(args = {})
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
      self.class.new(new_args)
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
