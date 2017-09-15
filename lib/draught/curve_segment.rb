require_relative './path'
require_relative './pathlike'
require_relative './boxlike'
require_relative './point'
require_relative './cubic_bezier'
require_relative './transformations'

module Draught
  # Beziér curve handling inspired mainly by Pomax's beziér tutorial <https://pomax.github.io/bezierinfo/> 
  # and `bezier.js` library: <https://github.com/Pomax/bezierjs>
  class CurveSegment
    include Boxlike
    include Pathlike

    class << self
      def build(args = {})
        if args.has_key?(:control_point_1)
          args = {
            start_point: args.fetch(:start_point),
            cubic_bezier: CubicBezier.new(args)
          }
        end
        new(args)
      end

      def from_path(path)
        if path.number_of_points != 2
          raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
        end
        unless path.first.is_a?(Point)
          raise ArgumentError, "the first point on the path must be a Point instance, this was #{path.first.inspect}"
        end
        unless path.last.is_a?(CubicBezier)
          raise ArgumentError, "the last point on the path must be a CubicBezier instance, this was #{path.last.inspect}"
        end

        build(start_point: path.first, cubic_bezier: path.last)
      end
    end

    attr_reader :start_point, :cubic_bezier

    def initialize(args)
      @start_point = args.fetch(:start_point)
      @cubic_bezier = args.fetch(:cubic_bezier)
    end

    def control_point_1
      @control_point_1 ||= cubic_bezier.control_point_1
    end

    def control_point_2
      @control_point_2 ||= cubic_bezier.control_point_2
    end

    def end_point
      @end_point ||= cubic_bezier.end_point
    end

    def points
      @points ||= [start_point, cubic_bezier]
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          Path.new(points[index_start_or_range])
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        Path.new(points[index_start_or_range, length])
      end
    end

    def translate(vector)
      self.class.build(Hash[
        transform_args_hash.map { |arg, point| [arg, point.translate(vector)] }
      ])
    end

    def transform(transformation)
      self.class.build(Hash[
        transform_args_hash.map { |arg, point| [arg, point.transform(transformation)] }
      ])
    end

    def lower_left
      @lower_left ||= Point.new(x_min, y_min)
    end

    def width
      @width ||= x_max - x_min
    end

    def height
      @height ||= y_max - y_min
    end

    private

    def transform_args_hash
      {start_point: start_point, cubic_bezier: cubic_bezier}
    end

    def x_max
      @x_max ||= extrema_points.map(&:x).max || 0
    end

    def x_min
      @x_min ||= extrema_points.map(&:x).min || 0
    end

    def y_max
      @y_max ||= extrema_points.map(&:y).max || 0
    end

    def y_min
      @y_min ||= extrema_points.map(&:y).min || 0
    end

    def extrema_points
      @extrema_points ||= extrema_t_values.map { |t| compute_point(t) }
    end

    def extrema_t_values
      @extrema_t_values ||= ([0.0 , 1.0] + extrema_values(:x) + extrema_values(:y)).sort.uniq
    end

    def extrema_values(axis)
      derivative_points[0..1].map { |points|
        derivative_roots(points.map(&axis))
      }.flatten.reject { |t| t < 0 || t > 1 }
    end

    def compute_point(t)
      return start_point if t == 0
      return end_point if t == 1

      t = t.to_f
      mt = 1 - t
      mt2 = mt * mt
      t2 = t * t
      a = mt2 * mt
      b = mt2 * t * 3
      c = mt * t2 * 3
      d = t * t2

      sp, cp1, cp2, ep = [start_point, control_point_1, control_point_2, end_point]

      x = (a * sp.x) + (b * cp1.x) + (c * cp2.x) + (d * ep.x)
      y = (a * sp.y) + (b * cp1.y) + (c * cp2.y) + (d * ep.y)

      Point.new(x, y)
    end

    def derivative_points
      @derivative_points ||= begin
        initial_points = [
          start_point, control_point_1, control_point_2, end_point
        ]
        [4,3,2].reduce([initial_points]) { |results, d|
          points = results.last
          c = (d - 1).to_f
          results << (0...c).map { |j|
            derivative_x = c * (points[j + 1].x - points[j].x)
            derivative_y = c * (points[j + 1].y - points[j].y)
            Point.new(derivative_x, derivative_y)
          }
        }[1..-1]
      end
    end

    def derivative_roots(points)
      points.length == 3 ? quadratic_roots(points) : linear_roots(points)
    end

    def quadratic_roots(points)
      a, b, c = points.map(&:to_f)
      d = a - (2 * b) + c

      if d != 0
        m1 = -Math.sqrt((b * b) - (a * c))
        m2 = -a + b
        v1 = -(m1 + m2) / d
        v2 = -(-m1 + m2) / d
        return [v1, v2]
      elsif b != c && d == 0
        return [((2 * b) - c)/(2 * (b - c))]
      end
      []
    end

    def linear_roots(points)
      a, b = points.map(&:to_f)
      if (a != b)
        return [a / (a - b)]
      end
      []
    end
  end
end
