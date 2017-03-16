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

    def ==(other)
      return false if length != other.length
      points.zip(other.points).all? { |a, b| a == b }
    end

    def translate(point)
      Path.new(points.map { |p| p.translate(point) })
    end

    protected

    def add_points(points)
      self.class.new(@points + points)
    end
  end
end
