require_relative 'point'
require_relative 'vector'

module Draught
  module Boxlike
    POSITION_METHODS = [:lower_left, :lower_centre, :lower_right, :centre_right, :upper_right, :upper_centre, :upper_left, :centre_left, :centre]

    # @return [World] the World
    def world
      raise NotImplementedError, "includers of Boxlike must implement #world"
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
      translation = world.vector.translation_between(reference_point, point)
      return self if translation == world.vector.null
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

    def min_gap
      0
    end

    private

    def invalid_position_method?(method_name)
      !valid_position_method?(method_name)
    end

    def valid_position_method?(method_name)
      POSITION_METHODS.include?(method_name)
    end
  end
end
