require_relative 'boxlike'
require_relative 'point'

module Draught
  class Sheet
    include Boxlike

    attr_reader :boxes, :lower_left, :width, :height

    def initialize(opts = {})
      @boxes = opts.fetch(:boxes)
      @lower_left = opts.fetch(:lower_left, Point::ZERO)
      @width = opts.fetch(:width)
      @height = opts.fetch(:height)
    end

    def translate(point)
      tr_lower_left = lower_left.translate(point)
      tr_boxes = boxes.map { |box| box.translate(point) }
      self.class.new(boxes: tr_boxes, lower_left: tr_lower_left, width: width, height: height)
    end

    def transform(transformer)
      tr_lower_left = lower_left.transform(transformer)
      tr_boxes = boxes.map { |box| box.transform(transformer) }
      tr_width, tr_height = transformer.call(width, height)
      self.class.new({
        boxes: tr_boxes, lower_left: tr_lower_left, width: tr_width, height: tr_height
      })
    end

    def ==(other)
      lower_left == other.lower_left && width == other.width && height == other.height && boxes == other.boxes
    end
  end
end
