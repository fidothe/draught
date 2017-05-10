require_relative './path'
require_relative './point'
require_relative './transformations'

module Draught
  class Line
    DEGREES_90 = Math::PI / 2
    DEGREES_180 = Math::PI
    DEGREES_270 = Math::PI * 1.5
    DEGREES_360 = Math::PI * 2

    class << self
      def horizontal(width)
        build(end_point: Point.new(width, 0)).path
      end

      def vertical(height)
        build(end_point: Point.new(0, height)).path
      end

      def build(args = {})
        builder_class = args.has_key?(:end_point) ? LineBuilderFromPoint : LineBuilderFromAngles
        line_args = builder_class.new(args).line_args
        new(line_args)
      end
    end

    attr_reader :end_point, :length, :radians

    def initialize(args)
      @end_point = args.fetch(:end_point)
      @length = args.fetch(:length)
      @radians = args.fetch(:radians)
    end

    def path
      @path ||= Path.new([Point::ZERO, end_point])
    end

    class LineBuilderFromAngles
      attr_reader :length, :radians
      private :length, :radians

      def initialize(args)
        @length = args.fetch(:length)
        @radians = args.fetch(:radians)
      end

      def line_args
        {length: length, radians: radians, end_point: end_point}
      end

      private

      def end_point
        hardwired_end_points.fetch(restricted_radians) {
          single_quadrant_end_point.transform(Transformations.rotate(remaining_angle))
        }
      end

      def restricted_radians
        @restricted_radians ||= restrict_to_360_degrees(radians)
      end

      def restrict_to_360_degrees(radians)
        radians % DEGREES_360
      end

      def hardwired_end_points
        {
          0 => Point.new(length,0),
          DEGREES_90 => Point.new(0,length),
          DEGREES_180 => Point.new(-length,0),
          DEGREES_270 => Point.new(0,-length),
          DEGREES_360 => Point.new(length,0)
        }
      end

      def single_quadrant_end_point
        Point.new(x, y)
      end

      def x
        Math.cos(single_quadrant_angle) * length
      end

      def y
        Math.sin(single_quadrant_angle) * length
      end

      def single_quadrant_angle
        @single_quadrant_angle ||= restricted_radians - remaining_angle
      end

      def remaining_angle
        @remaining_angle ||= begin
          [DEGREES_270, DEGREES_180, DEGREES_90, 0].find { |angle|
            restricted_radians > angle
          } || 0
        end
      end
    end

    class LineBuilderFromPoint
      attr_reader :end_point
      private :end_point

      def initialize(args)
        @end_point = args.fetch(:end_point)
      end

      def line_args
        {length: length, radians: radians, end_point: end_point}
      end

      private

      def length
        @length ||= Math.sqrt(x_length ** 2 + y_length ** 2)
      end

      def radians
        @radians ||= angle_to_start_of_quadrant + angle_ignoring_quadrant
      end

      def x_length
        @x_length = end_point.x.abs
      end

      def y_length
        @y_length ||= end_point.y.abs
      end

      def angle_to_start_of_quadrant
        which_side_of_x = end_point.x <=> 0
        which_side_of_y = end_point.y <=> 0

        case [which_side_of_x, which_side_of_y]
        when [1,0], [1, 1] # 0-90º
          0
        when [0,1], [-1, 1], [-1, 0] # 90-180º
          DEGREES_90
        when [-1, -1] # 180-270º
          DEGREES_180
        when [0, -1], [1, -1] # 270-360º
          DEGREES_270
        end
      end

      def angle_ignoring_quadrant
        Math.acos(y_length.to_f/length)
      end
    end
  end
end
