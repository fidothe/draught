require_relative 'boxlike'
require_relative 'extent'
require 'forwardable'

module Draught
  class Container
    extend Forwardable
    include Boxlike
    include Extent

    attr_reader :world, :box, :min_gap

    def_delegators :box, :extent, :containers

    def initialize(world, box, opts = {})
      @world = world
      @box = box
      @min_gap = opts.fetch(:min_gap, 0)
    end

    def translate(point)
      self.class.new(world, box.translate(point), {min_gap: min_gap})
    end

    def transform(transformer)
      transformed_min_gap = world.point.new(min_gap,0).transform(transformer).x
      self.class.new(world, box.transform(transformer), {min_gap: transformed_min_gap})
    end

    def ==(other)
      min_gap == other.min_gap && box == other.box
    end

    def box_type
      [:container]
    end

    def paths
      [box]
    end
  end
end
