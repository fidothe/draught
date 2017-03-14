require 'forwardable'

module Draught
  class Path
    extend Forwardable

    def self.build
      p = []
      yield(p)
      new.append(*p)
    end

    def_delegators :@points, :empty?

    def initialize(points = [])
      @points = points.dup.freeze
    end

    def points
      @points
    end

    def <<(point)
      append(point)
    end

    def append(*points)
      points.inject(self) { |path, point_or_path| path.add_points(point_or_path.points) }
    end

    protected

    def add_points(points)
      self.class.new(@points + points)
    end
  end
end
