require 'forwardable'

module Draught
  class Path
    extend Forwardable

    attr_reader :points

    def_delegators :points, :empty?, :length, :last

    def initialize(points = [])
      @points = points.dup.freeze
    end

    def <<(point)
      append(point)
    end

    def append(*points)
      points.inject(self) { |path, point_or_path| path.add_points(point_or_path.points) }
    end

    def translate(point)
      Path.new(points.map { |p| p.translate(point) })
    end

    def transform(transformation)
      Path.new(points.map { |p| p.transform(transformation) })
    end

    def lower_left
      @lower_left ||= Point.new(x_min, y_min)
    end

    def upper_right
      @upper_right ||= Point.new(x_max, y_max)
    end

    def ==(other)
      return false if length != other.length
      points.zip(other.points).all? { |a, b| a == b }
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
