require 'forwardable'
require_relative './boxlike'
require_relative './pathlike'
require_relative './style'

module Draught
  class Path
    include Boxlike
    include Pathlike

    attr_reader :world, :points

    # @param world [World] the world
    # @param args [Hash] the Path arguments.
    # @option args [Array<Draught::Point>] :points ([]) the points of the Path
    # @option args [Draught::Style] :style (nil) Styles that should be attached to the Path
    def initialize(world, args = {})
      @world = world
      @points = args.fetch(:points, []).dup.freeze
      @style = args.fetch(:style, nil)
    end

    def <<(point)
      append(point)
    end

    def append(*paths_or_points)
      paths_or_points.inject(self) { |path, point_or_path| path.add_points(point_or_path.points) }
    end

    def prepend(*paths_or_points)
      paths_or_points.inject(Path.new(world, points: [], style: style)) { |path, point_or_path|
        path.add_points(point_or_path.points)
      }.add_points(self.points)
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          self.class.new(world, points: points[index_start_or_range], style: style)
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        self.class.new(world, points: points[index_start_or_range, length], style: style)
      end
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

    def translate(vector)
      self.class.new(world, points: points.map { |p| p.translate(vector) }, style: style)
    end

    def transform(transformer)
      self.class.new(world, points: points.map { |p| p.transform(transformer) }, style: style)
    end

    def pretty_print(q)
      q.group(1, '(P', ')') do
        q.seplist(points, ->() { }) do |pointish|
          q.breakable
          q.pp pointish
        end
      end
    end

    def style
      @style ||= Style.new
    end

    def with_new_style(style)
      self.class.new(world, points: points, style: style)
    end

    protected

    def add_points(points)
      self.class.new(world, points: @points + points, style: style)
    end

    private

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
