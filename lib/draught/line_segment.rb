require_relative './line_segment/from_point'
require_relative './line_segment/from_angles'
require_relative './path'
require_relative './pathlike'
require_relative './boxlike'
require_relative './point'
require_relative './transformations'

module Draught
  # Represents a two-point line. Has length, and angle.
  class LineSegment
    DEGREES_90 = Math::PI / 2
    DEGREES_180 = Math::PI
    DEGREES_270 = Math::PI * 1.5
    DEGREES_360 = Math::PI * 2

    include Boxlike
    include Pathlike

    def self.build(world, args)
      builder_class = args.has_key?(:end_point) ? FromPoint : FromAngles
      line_segment_args = builder_class.build(world, args)
      new(world, line_segment_args)
    end

    attr_reader :world, :start_point, :end_point, :length, :radians
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] start_point
    #   @return [Point] the Point the LineSegment starts at
    # @!attribute [r] end_point
    #   @return [Point] the Point the LineSegment ends at
    # @!attribute [r] length
    #   @return [Number] the length of the LineSegment
    # @!attribute [r] radians
    #   @return [Number] the angle of the LineSegment in radians.

    # @param world [World] the world
    # @param args [Hash] the Path arguments.
    # @option args [Draught::Point] (PointBuilder.zero) :start_point the start Point of the line
    # @option args [Draught::Point] :end_point the end Point of the line
    # @option args [Number] :length the length of the line
    # @option args [Number] :radians the angle of the line, in radians
    # @option args [Draught::Metadata] :metadata (nil) a Metadata object that should be attached to the LineSegment
    def initialize(world, args)
      @world = world
      @start_point = args.fetch(:start_point, world.point.zero)
      @end_point = args.fetch(:end_point)
      @length = args.fetch(:length)
      @radians = args.fetch(:radians)
      @metadata = args.fetch(:metadata, nil)
    end

    def points
      @points ||= [start_point, end_point]
    end

    def center
      @center ||= compute_point(0.5)
    end

    def compute_point(t)
      return start_point if t == 0
      return end_point if t == 1

      t = t.to_f
      mt = 1 - t

      x = mt * start_point.x + t * end_point.x
      y = mt * start_point.y + t * end_point.y
      world.point.new(x, y)
    end

    def extend(args = {})
      default_args = {at: :end}
      args = default_args.merge(args)
      new_length = args[:to] || length + args[:by]
      new_line_segment = self.class.build(world, {
        start_point: start_point, length: new_length, radians: radians,
        metadata: metadata
      })
      args[:at] == :start ? shift_line_segment(new_line_segment) : new_line_segment
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          world.path.new(points: points[index_start_or_range], metadata: metadata)
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        world.path.new(points: points[index_start_or_range, length], metadata: metadata)
      end
    end

    def translate(vector)
      transformed_instance(->(arg, point) { [arg, point.translate(vector)] })
    end

    def transform(transformation)
      transformed_instance(->(arg, point) { [arg, point.transform(transformation)] })
    end

    def lower_left
      @lower_left ||= world.point.new(x_min, y_min)
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

    def line
      self
    end

    def curve?
      false
    end

    def split(t)
      split_point = compute_point(t)
      [
        self.class.build(world, start_point: start_point, end_point: split_point),
        self.class.build(world, start_point: split_point, end_point: end_point)
      ]
    end

    def pretty_print(q)
      q.group(1, '(Pl', ')') do
        q.seplist(points, ->() { }) do |point|
          q.breakable
          q.pp point
        end
      end
    end

    def with_metadata(metadata)
      self.class.new(world, {
        start_point: start_point, end_point: end_point, length: length, radians: radians,
        metadata: metadata
      })
    end

    private

    def shift_line_segment(new_line_segment)
      translation = world.vector.translation_between(new_line_segment.end_point, end_point)
      self.class.new(world, {
        start_point: start_point.translate(translation),
        end_point: new_line_segment.end_point.translate(translation),
        length: new_line_segment.length,
        radians: radians,
        metadata: metadata,
      })
    end

    def transformed_instance(mapper)
      args = transform_args_hash.map(&mapper).to_h
      args[:metadata] = metadata
      self.class.build(world, args)
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
  end
end
