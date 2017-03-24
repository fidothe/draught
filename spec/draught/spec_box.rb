require 'draught/point'
require 'draught/boxlike'

module Draught
  class SpecBox
    include Boxlike

    attr_reader :lower_left, :min_gap, :width, :height

    def self.zeroed(opts = {})
      new(opts.merge(lower_left: Point::ZERO))
    end

    def initialize(opts = {})
      @lower_left = opts.fetch(:lower_left)
      @width = opts.fetch(:width)
      @height = opts.fetch(:height)
      @min_gap = opts.fetch(:min_gap, 0)
    end

    def translate(point)
      self.class.new({
        lower_left: lower_left.translate(point),
        width: width, height: height,
        min_gap: min_gap
      })
    end

    def transform(transformer)
      new_origin = lower_left.transform(transformer)
      new_upper_right = upper_right.transform(transformer)
      new_width = new_upper_right.x - new_origin.x
      new_height = new_upper_right.y - new_origin.y
      self.class.new({
        lower_left: new_origin,
        width: new_width, height: new_height,
        min_gap: min_gap
      })
    end
  end
end
