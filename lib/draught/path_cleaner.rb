require_relative 'path'

module Draught
  class PathCleaner
    def self.dedupe(path)
      Path.new(new(path.points).dedupe)
    end

    def self.simplify(path)
      Path.new(new(path.points).simplify)
    end

    attr_reader :input_points

    def initialize(input_points)
      @input_points = input_points
    end

    def dedupe
      output_points = [input_points.first]
      input_points.inject do |previous_point, point|
        output_points << point if point != previous_point
        point
      end
      output_points
    end

    def simplify
      points = dedupe
      pos = 0
      while pos < (points.length - 2)
        triple = points[pos, 3]
        if intercepts?(*triple)
          points.delete_at(pos + 1)
        else
          pos += 1
        end
      end
      points
    end

    private

    def intercepts?(previous_point, point, next_point)
      intercepts_horizontal?(previous_point, point, next_point) ||
        intercepts_vertical?(previous_point, point, next_point)
    end

    def intercepts_horizontal?(previous_point, point, next_point)
      points = [previous_point, point, next_point]
      intercepts_line?(points, :x)
    end

    def intercepts_vertical?(previous_point, point, next_point)
      points = [previous_point, point, next_point]
      intercepts_line?(points, :y)
    end

    def intercepts_line?(points, axis)
      axis_aligned?(points, perpendicular_axis(axis)) && obviously_intermediate?(points, axis)
    end

    def perpendicular_axis(axis)
      {:x => :y, :y => :x}.fetch(axis)
    end

    def axis_aligned?(points, axis)
      points.map(&axis).uniq.length == 1
    end

    def obviously_intermediate?(points, axis)
      p1, p2, p3 = points.map(&axis)
      operator = p1 < p3 ? :< : :>
      p1.send(operator, p2) && p2.send(operator, p3)
    end
  end
end
