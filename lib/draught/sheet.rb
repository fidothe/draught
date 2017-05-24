require_relative 'boxlike'
require_relative 'point'

module Draught
  class Sheet
    include Boxlike

    attr_reader :containers, :lower_left, :width, :height

    def initialize(opts = {})
      @containers = opts.fetch(:containers)
      @lower_left = opts.fetch(:lower_left, Point::ZERO)
      @width = opts.fetch(:width)
      @height = opts.fetch(:height)
    end

    def translate(point)
      tr_lower_left = lower_left.translate(point)
      tr_containers = containers.map { |container| container.translate(point) }
      self.class.new(containers: tr_containers, lower_left: tr_lower_left, width: width, height: height)
    end

    def transform(transformer)
      tr_lower_left = lower_left.transform(transformer)
      tr_containers = containers.map { |container| container.transform(transformer) }
      extent = Point.new(width, height).transform(transformer)
      tr_width, tr_height = extent.x, extent.y
      self.class.new({
        containers: tr_containers, lower_left: tr_lower_left, width: tr_width, height: tr_height
      })
    end

    def paths
      containers
    end

    def box_type
      [:container]
    end

    def ==(other)
      lower_left == other.lower_left && width == other.width && height == other.height && containers == other.containers
    end
  end
end
