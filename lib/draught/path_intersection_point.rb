require_relative './pointlike'
require_relative './tolerance/x_y_comparable'
require 'forwardable'

module Draught
  class PathIntersectionPoint
    extend Forwardable
    include Tolerance::XYComparable

    attr_reader :point, :world, :paths

    def_delegators :point, :x, :y
    def_delegators :world, :tolerance


    def initialize(world, point, paths)
      @world, @point, @paths = world, point, paths
    end

    def compare_compatible?(other)
      self.class === other && other.paths == paths
    end

    def pretty_print(q)
      q.group(1, '', '') do
        q.text "#{x},#{y}"
      end
    end
  end
end
