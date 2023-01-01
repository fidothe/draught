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

    def initialize(world, args)
      @world = world
      @start_point = args.fetch(:start_point, world.point.zero)
      @end_point = args.fetch(:end_point)
      @length = args.fetch(:length)
      @radians = args.fetch(:radians)
      @style = args.fetch(:style, nil)
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
        start_point: start_point, length: new_length, radians: radians
      })
      args[:at] == :start ? shift_line_segment(new_line_segment) : new_line_segment
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          world.path.new(points: points[index_start_or_range], style: style)
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        world.path.new(points: points[index_start_or_range, length], style: style)
      end
    end

    def translate(vector)
      translated_args = transform_args_hash.map { |arg, point| [arg, point.translate(vector)] }.to_h
      translated_args[:style] = style
      self.class.build(world, translated_args)
    end

    def transform(transformation)
      transformed_args = transform_args_hash.map { |arg, point| [arg, point.transform(transformation)] }.to_h
      transformed_args[:style] = style
      self.class.build(world, transformed_args)
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

    def style
      @style ||= Style.new
    end

    def with_new_style(style)
      self.class.new(world, {start_point: start_point, end_point: end_point, length: length, radians: radians, style: style})
    end

    private

    def shift_line_segment(new_line_segment)
      translation = world.vector.translation_between(new_line_segment.end_point, end_point)
      self.class.new(world, {
        start_point: start_point.translate(translation),
        end_point: new_line_segment.end_point.translate(translation),
        length: new_line_segment.length,
        radians: radians,
        style: style
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
  end
end
