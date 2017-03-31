require_relative 'boxlike'
require 'forwardable'

module Draught
  class Container
    extend Forwardable
    include Boxlike

    attr_reader :box, :min_gap

    def_delegators :box, :lower_left, :width, :height, :paths, :containers

    def initialize(box, opts = {})
      @box = box
      @min_gap = opts.fetch(:min_gap, 0)
    end

    def translate(point)
      self.class.new(box.translate(point), {min_gap: min_gap})
    end

    def transform(transformer)
      transformed_min_gap = Point.new(min_gap,0).transform(transformer).x
      self.class.new(box.transform(transformer), {min_gap: transformed_min_gap})
    end

    def ==(other)
      min_gap == other.min_gap && box == other.box
    end
  end
end
