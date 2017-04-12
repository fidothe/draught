require_relative 'sheet'
require_relative 'point'

module Draught
  class SheetBuilder
    attr_reader :max_height, :max_width, :outer_gap

    def self.build(opts = {}, &block)
      builder = new(opts)
      builder.instance_exec(&block)
      builder.sheet
    end

    def initialize(opts = {})
      @max_width = opts.fetch(:max_width)
      @max_height = opts.fetch(:max_height)
      @outer_gap = opts.fetch(:outer_gap, 0)
      @boxes_to_nest = []
    end

    def add(box)
      @boxes_to_nest << box
    end

    def sheet
      containers = nested
      Sheet.new({
        lower_left: Point::ZERO,
        containers: containers,
        width: width(containers),
        height: height(containers)
      })
    end

    private

    def nested
      full = false
      boxes = []
      @boxes_to_nest.cycle do |box|
        break if full
        placement_point = find_placement_point(box, boxes)
        if placement_point
          boxes << box.move_to(placement_point)
        else
          full = true
        end
      end
      boxes.map { |box| box.translate(origin_offset) }
    end

    def width(boxes)
      min_x = boxes.map { |box| box.lower_left.x }.min
      max_x = boxes.map { |box| box.upper_right.x }.max
      (max_x - min_x) + (2 * outer_gap)
    end

    def height(boxes)
      min_y = boxes.map { |box| box.lower_left.y }.min
      max_y = boxes.map { |box| box.upper_right.y }.max
      (max_y - min_y) + (2 * outer_gap)
    end

    def find_placement_point(box, placed_boxes)
      return Point::ZERO if placeable_at_location?(box, Point::ZERO, placed_boxes)
      placement_after_a_box(box, placed_boxes) || placement_above_a_box(box, placed_boxes)
    end

    def placement_after_a_box(box, placed_boxes)
      placement_around_a_box(box, placed_boxes, :lower_right)
    end

    def placement_above_a_box(box, placed_boxes)
      placement_around_a_box(box, placed_boxes, :upper_left)
    end

    def placement_around_a_box(box, placed_boxes, reference_point_method)
      reference_box = placed_boxes.find { |reference_box|
        point = offset(box, reference_box, reference_point_method)
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
        Vector.new(gap, 0)
      when :upper_left
        Vector.new(0, gap)
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
      Vector.new(outer_gap, outer_gap)
    end
  end
end
