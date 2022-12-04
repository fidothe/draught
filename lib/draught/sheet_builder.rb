require_relative 'sheet'
require_relative 'point'

module Draught
  class SheetBuilder
    attr_reader :world, :max_height, :max_width, :outer_gap, :boxes

    def self.sheet(world, args)
      new(world, args).sheet
    end

    def initialize(world, opts = {})
      @world = world
      @max_width = opts.fetch(:max_width)
      @max_height = opts.fetch(:max_height)
      @outer_gap = opts.fetch(:outer_gap, 0)
      @boxes = opts.fetch(:boxes)
    end

    def sheet
      containers = nested
      Sheet.new(world, {
        lower_left: world.point.zero,
        containers: containers,
        width: width(containers),
        height: height(containers)
      })
    end

    def ==(other)
      comparison_args.inject(true) { |ok, meth_name|
        send(meth_name) == other.send(meth_name) && ok
      }
    end

    private

    def comparison_args
      [:max_width, :max_height, :outer_gap, :boxes]
    end

    def containers
      @containers ||= nested
    end

    def nested
      full = false
      nested_boxes = []
      boxes.cycle do |box|
        break if full
        placement_point = find_placement_point(box, nested_boxes)
        if placement_point
          nested_boxes << box.move_to(placement_point)
        else
          full = true
        end
      end
      nested_boxes.map { |box| box.translate(origin_offset) }
    end

    def width(boxes)
      edge_length(boxes, :left_edge, :right_edge)
    end

    def height(boxes)
      edge_length(boxes, :bottom_edge, :top_edge)
    end

    def edge_length(boxes, min_method, max_method)
      min = boxes.map(&min_method).min
      max = boxes.map(&max_method).max
      (max - min) + (2 * outer_gap)
    end

    def find_placement_point(box, placed_boxes)
      return world.point.zero if placeable_at_location?(box, world.point.zero, placed_boxes)
      placement_after_a_box(box, placed_boxes) || placement_above_a_box(box, placed_boxes)
    end

    def placement_after_a_box(box, placed_boxes)
      placement_around_a_box(box, placed_boxes, :lower_right)
    end

    def placement_above_a_box(box, placed_boxes)
      placement_around_a_box(box, placed_boxes, :upper_left)
    end

    def placement_around_a_box(box, placed_boxes, reference_point_method)
      reference_box = placed_boxes.find { |placed_box|
        point = offset(box, placed_box, reference_point_method)
        placeable_at_location?(box, point, placed_boxes)
      }
      if reference_box
        return offset(box, reference_box, reference_point_method)
      end
      false
    end

    def offset(box, reference_box, reference_point_method)
      gap = [box.min_gap, reference_box.min_gap].max
      offset_point(gap, reference_box, reference_point_method)
    end

    def offset_point(gap, box, reference_point_method)
      offset = offset_translation(gap, reference_point_method)
      box.send(reference_point_method).translate(offset)
    end

    def offset_translation(gap, reference_point_method)
      case reference_point_method
      when :lower_right
        world.vector.new(gap, 0)
      when :upper_left
        world.vector.new(0, gap)
      end
    end

    def placeable_at_location?(box, placement_point, placed_boxes)
      box_to_place = box.move_to(placement_point)
      no_overlaps?(box_to_place, placed_boxes) && fits?(box_to_place)
    end

    def no_overlaps?(box, placed_boxes)
      placed_boxes.none? { |placed_box| box.overlaps?(placed_box) }
    end

    def fits?(box)
      x = 0..usable_width
      y = 0..usable_height
      box.corners.all? { |point| x.include?(point.x) && y.include?(point.y) }
    end

    def usable_width
      @usable_width ||= max_width - (2 * outer_gap)
    end

    def usable_height
      @usable_height ||= max_height - (2 * outer_gap)
    end

    def origin_offset
      world.vector.new(outer_gap, outer_gap)
    end
  end
end
