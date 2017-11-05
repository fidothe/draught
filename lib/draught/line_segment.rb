require_relative './path'
require_relative './pathlike'
require_relative './boxlike'
require_relative './point'
require_relative './transformations'

module Draught
  class LineSegment
    DEGREES_90 = Math::PI / 2
    DEGREES_180 = Math::PI
    DEGREES_270 = Math::PI * 1.5
    DEGREES_360 = Math::PI * 2

    include Boxlike
    include Pathlike

    class << self
      def horizontal(width)
        build(end_point: Point.new(width, 0))
      end

      def vertical(height)
        build(end_point: Point.new(0, height))
      end

      def build(args = {})
        builder_class = args.has_key?(:end_point) ? LineSegmentBuilderFromPoint : LineSegmentBuilderFromAngles
        line_segment_args = builder_class.new(args).line_segment_args
        new(line_segment_args)
      end

      def from_path(path)
        if path.number_of_points != 2
          raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
        end
        build(start_point: path.first, end_point: path.last)
      end
    end

    attr_reader :start_point, :end_point, :length, :radians

    def initialize(args)
      @start_point = args.fetch(:start_point, Point::ZERO)
      @end_point = args.fetch(:end_point)
      @length = args.fetch(:length)
      @radians = args.fetch(:radians)
    end

    def points
      @points ||= [start_point, end_point]
    end

    def compute_point(t)
      return start_point if t == 0
      return end_point if t == 1

      t = t.to_f
      mt = 1 - t

      x = mt * start_point.x + t * end_point.x
      y = mt * start_point.y + t * end_point.y
      Point.new(x, y)
    end

    def extend(args = {})
      default_args = {at: :end}
      args = default_args.merge(args)
      new_length = args[:to] || length + args[:by]
      new_line_segment = self.class.build({
        start_point: start_point, length: new_length, radians: radians
      })
      args[:at] == :start ? shift_line_segment(new_line_segment) : new_line_segment
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          Path.new(points[index_start_or_range])
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        Path.new(points[index_start_or_range, length])
      end
    end

    def translate(vector)
      self.class.build(Hash[
        transform_args_hash.map { |arg, point| [arg, point.translate(vector)] }
      ])
    end

    def transform(transformation)
      self.class.build(Hash[
        transform_args_hash.map { |arg, point| [arg, point.transform(transformation)] }
      ])
    end

    def lower_left
      @lower_left ||= Point.new(x_min, y_min)
    end

    def width
      @width ||= x_max - x_min
    end

    def height
      @height ||= y_max - y_min
    end

    def line?
      true
    end

    def curve?
      false
    end

    private

    def shift_line_segment(new_line_segment)
      translation = Vector.translation_between(new_line_segment.end_point, end_point)
      self.class.new({
        start_point: start_point.translate(translation),
        end_point: new_line_segment.end_point.translate(translation),
        length: new_line_segment.length,
        radians: radians
      })
    end

    def transform_args_hash
      {start_point: start_point, end_point: end_point}
    end

    def compute_coord(coord_set, t)
      (1 - t) * start_point.send(coord_set) + t * end_point.send(coord_set)
    end

    def x_max
      @x_max ||= points.map(&:x).max || 0
    end

    def x_min
      @x_min ||= points.map(&:x).min || 0
    end

    def y_max
      @y_max ||= points.map(&:y).max || 0
    end

    def y_min
      @y_min ||= points.map(&:y).min || 0
    end

    class LineSegmentBuilderFromAngles
      attr_reader :start_point, :length, :radians
      private :start_point, :length, :radians

      def initialize(args)
        @start_point = args.fetch(:start_point, Point::ZERO)
        @length = args.fetch(:length)
        @radians = args.fetch(:radians)
      end

      def line_segment_args
        {length: length, radians: radians, start_point: start_point, end_point: end_point}
      end

      private

      def end_point
        end_point_from_zero.translate(Vector.translation_between(Point::ZERO, start_point))
      end

      def end_point_from_zero
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

    class LineSegmentBuilderFromPoint
      attr_reader :start_point, :end_point
      private :start_point, :end_point

      def initialize(args)
        @start_point = args.fetch(:start_point, Point::ZERO)
        @end_point = args.fetch(:end_point)
      end

      def line_segment_args
        {length: length, radians: radians, start_point: start_point, end_point: end_point}
      end

      private

      def end_point_from_zero
        @end_point_from_zero ||= end_point.translate(Vector.translation_between(start_point, Point::ZERO))
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
