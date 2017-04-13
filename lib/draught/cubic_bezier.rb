require_relative './point'

module Draught
  class CubicBezier
    attr_reader :end_point, :control_point_1, :control_point_2

    def initialize(args = {})
      @end_point = args.fetch(:end_point)
      @control_point_1 = args.fetch(:control_point_1)
      @control_point_2 = args.fetch(:control_point_2)
    end

    def ==(other)
      other.end_point == end_point && other.control_point_1 == control_point_1 && other.control_point_2 == control_point_2
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
  end
end
