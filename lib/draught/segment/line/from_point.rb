module Draught
  module Segment
    class Line
      class FromPoint
        attr_reader :world, :start_point, :end_point, :metadata
        private :start_point, :end_point, :metadata

        def self.build(...)
          new(...).line_segment_args
        end

        def initialize(world, start_point: world.point.zero, end_point:, metadata: nil)
          @world = world
          @start_point, @end_point, @metadata = start_point.position_point, end_point.position_point, metadata
        end

        def line_segment_args
          {length: length, radians: radians, start_point: start_point, end_point: end_point, metadata: metadata}
        end

        private

        def end_point_from_zero
          @end_point_from_zero ||= end_point.translate(world.vector.translation_between(start_point, world.point.zero))
        end

        def length
          @length ||= calculate_length
        end

        def radians
          @radians ||= calculate_radians
        end

        def x_length
          @x_length ||= end_point_from_zero.x.abs
        end

        def y_length
          @y_length ||= end_point_from_zero.y.abs
        end

        def angle_to_start_of_quadrant
          @angle_to_start_of_quadrant ||= calculate_angle_to_start_of_quadrant
        end

        def angle_to_end_of_quadrant
          @angle_to_end_of_quadrant ||= calculate_angle_to_end_of_quadrant
        end

        def angle_ignoring_quadrant
          Math.asin(y_length.to_f/length)
        end

        private

        def calculate_angle_to_start_of_quadrant
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

        def calculate_angle_to_end_of_quadrant
          which_side_of_x = end_point_from_zero.x <=> 0
          which_side_of_y = end_point_from_zero.y <=> 0

          case [which_side_of_x, which_side_of_y]
          when [1,0], [1, 1] # 0-90º
            DEGREES_90
          when [0,1], [-1, 1] # 90-180º
            DEGREES_180
          when [-1, 0], [-1, -1] # 180-270º
            DEGREES_270
          when [0, -1], [1, -1] # 270-360º
            DEGREES_360
          end
        end

        # We can calculate the angle by treating the points as either end of the
        # hypotenuse of a right angle triangle whose other sides are the lengths
        # on the x and y axis. If we translate the start point to (0,0) and ignore
        # the sign of the coordinates of the end point, then we have a nice simple
        # use for arcsine or arccosine to work out the angle between the y == 0
        # line and the hypotenuse.
        #
        # We can then figure out from the signs of the translated end point which
        # quadrant (0-90, 90-180, 180-270, 270-360) it's in, and use that to
        # figure out how much we need to add to the unsigned end point angle to
        # get the real angle.
        #
        # For the first quadrant, we just use the angle we calculated. For the
        # second (90-180), we need to subtract the calculated angle from 180, for
        # the third (180-270) we add the calculated angle to 180, and for the last
        # we subtract the angle from 360.
        def calculate_radians
          if x_length == 0 || y_length == 0
            angle_to_start_of_quadrant
          else
            case angle_to_end_of_quadrant
            when DEGREES_90
              angle_ignoring_quadrant
            when DEGREES_180
              DEGREES_180 - angle_ignoring_quadrant
            when DEGREES_270
              DEGREES_180 + angle_ignoring_quadrant
            else
              DEGREES_360 - angle_ignoring_quadrant
            end
          end
        end

        def calculate_length
          if x_length == 0 || y_length == 0
            x_length + y_length
          else
            Math.sqrt(x_length ** 2 + y_length ** 2)
          end
        end
      end
    end
  end
end
