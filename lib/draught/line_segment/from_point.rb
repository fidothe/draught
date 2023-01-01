module Draught
  class LineSegment
    class FromPoint
      attr_reader :world, :start_point, :end_point, :style
      private :start_point, :end_point, :style

      def self.build(world, args)
        new(world, args).line_segment_args
      end

      def initialize(world, args)
        @world = world
        @start_point = args.fetch(:start_point, world.point.zero)
        @end_point = args.fetch(:end_point)
        @style = args.fetch(:style, nil)
      end

      def line_segment_args
        {length: length, radians: radians, start_point: start_point, end_point: end_point, style: style}
      end

      private

      def end_point_from_zero
        @end_point_from_zero ||= end_point.translate(world.vector.translation_between(start_point, world.point.zero))
      end


      def length
        @length ||= begin
          if x_length == 0 || y_length == 0
            x_length + y_length
          else
            Math.sqrt(x_length ** 2 + y_length ** 2)
          end
        end
      end

      def radians
        @radians ||= begin
          if x_length == 0 || y_length == 0
            angle_to_start_of_quadrant
          else
            angle_to_start_of_quadrant + angle_ignoring_quadrant
          end
        end
      end

      def x_length
        @x_length = end_point_from_zero.x.abs
      end

      def y_length
        @y_length ||= end_point_from_zero.y.abs
      end

      def angle_to_start_of_quadrant
        which_side_of_x = end_point_from_zero.x <=> 0
        which_side_of_y = end_point_from_zero.y <=> 0

        case [which_side_of_x, which_side_of_y]
        when [1,0], [1, 1] # 0-90º
          0
        when [0,1], [-1, 1] # 90-180º
          DEGREES_90
        when [-1, 0], [-1, -1] # 180-270º
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
