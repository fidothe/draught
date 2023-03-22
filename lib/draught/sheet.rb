require_relative 'boxlike'
require_relative 'extent'
require_relative 'point'

module Draught
  class Sheet
    include Boxlike
    include Extent

    attr_reader :world, :containers, :lower_left, :width, :height

    def initialize(world, containers:, lower_left: nil, width:, height:)
      @world = world
      @containers, @width, @height = containers, width, height
      @lower_left = lower_left || world.point.zero
    end

    # @return [Draught::Extent] the Extent for this Sheet
    def extent
      @extent ||= Draught::Extent::Instance.new(world, items: [lower_left, world.point(lower_left.x + width, lower_left.y + height)])
    end

    def translate(point)
      tr_lower_left = lower_left.translate(point)
      tr_containers = containers.map { |container| container.translate(point) }
      self.class.new(world, containers: tr_containers, lower_left: tr_lower_left, width: width, height: height)
    end

    def transform(transformer)
      tr_lower_left = lower_left.transform(transformer)
      tr_containers = containers.map { |container| container.transform(transformer) }
      new_upper_right = world.point.new(width, height).transform(transformer)
      tr_width, tr_height = new_upper_right.x, new_upper_right.y
      self.class.new(world, containers: tr_containers, lower_left: tr_lower_left, width: tr_width, height: tr_height)
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
