require 'forwardable'
require_relative 'boxlike'

module Draught
  class Path
    extend Forwardable
    include Boxlike

    attr_reader :points

    def_delegators :points, :empty?, :length, :first, :last

    def initialize(points = [])
      @points = points.dup.freeze
    end

    def <<(point)
      append(point)
    end

    def append(*points)
      points.inject(self) { |path, point_or_path| path.add_points(point_or_path.points) }
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          self.class.new(points[index_start_or_range])
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        self.class.new(points[index_start_or_range, length])
      end
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

    def ==(other)
      return false if length != other.length
      points.zip(other.points).all? { |a, b| a == b }
    end

    def approximates?(other, delta)
      return false if length != other.length
      points.zip(other.points).all? { |a, b| a.approximates?(b, delta) }
    end

    def translate(point)
      self.class.new(points.map { |p| p.translate(point) })
    end

    def transform(transformer)
      self.class.new(points.map { |p| p.transform(transformer) })
    end

    def paths
      [self]
    end

    def containers
      []
    end

    protected

    def add_points(points)
      self.class.new(@points + points)
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
