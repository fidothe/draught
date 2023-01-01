require_relative 'path'

module Draught
  class PathCleaner
    def self.dedupe(world, path)
      world.path.new(points: new(path.points).dedupe, style: path.style)
    end

    def self.simplify(world, path)
      world.path.new(points: new(path.points).simplify, style: path.style)
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
      intercepts_line_segment?(points, :x)
    end

    def intercepts_vertical?(previous_point, point, next_point)
      points = [previous_point, point, next_point]
      intercepts_line_segment?(points, :y)
    end

    def intercepts_line_segment?(points, axis)
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
