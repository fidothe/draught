require 'forwardable'

module Draught
  class Path
    extend Forwardable

    def_delegators :@points, :empty?, :[]

    def initialize(points = [])
      @points = points.dup.freeze
    end

    def to_a
      @points.dup
    end

    def <<(point)
      add_points([point])
    end

    def add_points(points)
      self.class.new(@points + points)
    end
  end
end
