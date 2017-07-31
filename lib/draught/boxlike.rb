require_relative 'point'
require_relative 'vector'

module Draught
  module Boxlike
    POSITION_METHODS = [:lower_left, :lower_centre, :lower_right, :centre_right, :upper_right, :upper_centre, :upper_left, :centre_left, :centre]

    def lower_left
      raise NotImplementedError, "includers of Boxlike must implement #lower_left"
    end

    def width
      raise NotImplementedError, "includers of Boxlike must implement #width"
    end

    def height
      raise NotImplementedError, "includers of Boxlike must implement #height"
    end

    def box_type
      raise NotImplementedError, "includers of Boxlike must implement #box_type"
    end

    def lower_right
      @lower_right ||= lower_left.translate(Draught::Vector.new(width, 0))
    end

    def upper_right
      @upper_right ||= lower_left.translate(Draught::Vector.new(width, height))
    end

    def upper_left
      @upper_left ||= lower_left.translate(Draught::Vector.new(0, height))
    end

    def centre_left
      @centre_left ||= lower_left.translate(Draught::Vector.new(0, height/2.0))
    end

    def lower_centre
      @lower_centre ||= lower_left.translate(Draught::Vector.new(width/2.0, 0))
    end

    def centre_right
      @centre_right ||= lower_right.translate(Draught::Vector.new(0, height / 2.0))
    end

    def upper_centre
      @upper_centre ||= upper_left.translate(Draught::Vector.new(width/2.0, 0))
    end

    def centre
      @centre ||= lower_left.translate(Draught::Vector.new(width/2.0, height/2.0))
    end

    def corners
      [lower_left, lower_right, upper_right, upper_left]
    end

    def left_edge
      @left_edge ||= lower_left.x
    end

    def right_edge
      @right_edge ||= upper_right.x
    end

    def top_edge
      @top_edge ||= upper_right.y
    end

    def bottom_edge
      @bottom_edge ||= lower_left.y
    end

    def move_to(point, opts = {})
      reference_position_method = opts.fetch(:position, :lower_left)
      if invalid_position_method?(reference_position_method)
        raise ArgumentError, ":position option must be a valid position (one of #{POSITION_METHODS.map(&:inspect).join(', ')}), rather than #{opts[:position].inspect}" 
      end

      reference_point = send(reference_position_method)
      translation = Draught::Vector.translation_between(reference_point, point)
      return self if translation == Draught::Vector::NULL
      translate(translation)
    end

    def translate(point)
      raise NotImplementedError
    end

    def transform(transformer)
      raise NotImplementedError
    end

    def paths
      raise NotImplementedError
    end

    def containers
      raise NotImplementedError
    end

    def overlaps?(other_box)
      !disjoint?(other_box)
    end

    def disjoint?(other_box)
      horizontal_disjoint?(other_box) || vertical_disjoint?(other_box)
    end

    def include_point?(point)
      horizontal_extent.include?(point.x) && vertical_extent.include?(point.y)
    end

    def min_gap
      0
    end

    private

    def horizontal_disjoint?(other_box)
      other_box.left_edge == right_edge || other_box.right_edge == left_edge ||
        other_box.left_edge > right_edge || other_box.right_edge < left_edge
    end

    def vertical_disjoint?(other_box)
      other_box.bottom_edge == top_edge || other_box.top_edge == bottom_edge ||
        other_box.top_edge < bottom_edge || other_box.bottom_edge > top_edge
    end

    def horizontal_extent
      @horizontal_extent ||= lower_left.x..upper_right.x
    end

    def vertical_extent
      @vertical_extent ||= lower_left.y..upper_right.y
    end

    def invalid_position_method?(method_name)
      !valid_position_method?(method_name)
    end

    def valid_position_method?(method_name)
      POSITION_METHODS.include?(method_name)
    end
  end
end
