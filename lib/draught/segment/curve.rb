require_relative '../pathlike'
require_relative '../boxlike'
require_relative '../segmentlike'
require_relative '../extent'
require_relative '../point'
require_relative '../cubic_bezier'
require_relative '../de_casteljau'

module Draught
  module Segment
    # Beziér curve handling inspired mainly by Pomax's beziér tutorial
    # <https://pomax.github.io/bezierinfo/> and `bezier.js` library
    # <https://github.com/Pomax/bezierjs>
    class Curve
      LUT_SIZE = 100
      LUT_STEP_SIZE = 1.0/LUT_SIZE


      include Boxlike
      include Pathlike
      include Segmentlike
      include Extent

      class << self
        def build(world, args = {})
          if args.has_key?(:control_point_1)
            args = {
              start_point: args.fetch(:start_point),
              cubic_bezier: Draught::CubicBezier.new(world, args),
              metadata: args.fetch(:metadata, nil)
            }
          end
          new(world, **args)
        end
      end

      attr_reader :world, :start_point, :cubic_bezier
      # @!attribute [r] world
      #   @return [World] the World
      # @!attribute [r] start_point
      #   @return [Point] the Point the CurveSegment starts at
      # @!attribute [r] cubic_bezier
      #   @return [CubicBezier] the CubicBezier portion of the CurveSegment

      # @param world [World] the world
      # @param args [Hash] the Path arguments.
      # @option args [Array<Draught::Point>] :points ([]) the points of the Path
      # @option args [Draught::Metadata::Instance] :metadata (nil) Metadata that should be attached to the CurveSegment
      def initialize(world, start_point:, cubic_bezier:, metadata: nil)
        @world, @start_point, @cubic_bezier, @metadata = world, start_point, cubic_bezier, metadata
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
            world.path.new(points: points[index_start_or_range], metadata: metadata)
          when Numeric
            points[index_start_or_range]
          else
            raise TypeError, "requires a Range or Numeric in single-arg form"
          end
        else
          world.path.new(points: points[index_start_or_range, length], metadata: metadata)
        end
      end

      # @return [Draught::Path] a new Path with the same points as this Segment::Curve
      def to_path
        @path ||= world.path.new(points: points, metadata: metadata)
      end

      def translate(vector)
        transformed_instance(->(arg, point) { [arg, point.translate(vector)] })
      end

      def transform(transformation)
        transformed_instance(->(arg, point) { [arg, point.transform(transformation)] })
      end

      # @return [Draught::Extent] the Extent for this Segment
      def extent
        @extent ||= Draught::Extent::Instance.new(world, items: extrema_points)
      end

      def line?
        false
      end

      def curve?
        true
      end

      # Turn a t value into its Point value
      #
      # @param t [Float] the value of t on the curve
      # @return [Draught::Point] the point on the curve at t
      def compute_point(t)
        return start_point if t == 0
        return end_point if t == 1

        a, b, c, d = compute_abcd(t.to_f)

        x = compute_axis_value(:x, a, b, c, d)
        y = compute_axis_value(:y, a, b, c, d)

        world.point.new(x, y)
      end

      # Project a point (x,y) onto the curve (t)
      #
      # @param point [Draught::Point] the point to project
      # @return [Float] the t value of the closest point on the curve to +point+
      def project_point(point)
        closest_lut_t, closest_lut_point = lut.min_by { |t, lut_point| point_distance(lut_point, point) }
        current_min_distance = point_distance(closest_lut_point, point)

        find_closest(point, current_min_distance, closest_lut_t)
      end

      def compute_y_axis_value(t)
        extrema_axis_value_computer(:y, t)
      end

      def compute_x_axis_value(t)
        extrema_axis_value_computer(:x, t)
      end

      # @param t [Float] the t value of the curve to split at
      # @return [Array<CurveSegment>] a two-item array containing the pre- and post-split curves
      def split(t)
        de_casteljau.split(self, t)
      end

      # @return [LineSegment] the line between start and end point
      def line
        world.line_segment.build(start_point: start_point, end_point: end_point)
      end

      def pretty_print(q)
        q.group(1, '(Pc', ')') do
          q.seplist([start_point, cubic_bezier], ->() { }) do |pointish|
            q.breakable
            q.pp pointish
          end
        end
      end

      # return a copy of this object with different metadata attached
      #
      # @param style [Metadata::Instance] the metadata to use
      # @return [Segment::Curve] the copy of this curve segment with new metadata
      def with_metadata(metadata)
        self.class.new(world, metadata: metadata, **transform_args_hash)
      end

      private

      def lut
        @lut ||= generate_lut
      end

      def generate_lut
        lut = []
        LUT_SIZE.times.inject(0) { |t, _|
          lut << [t, compute_point(t)]
          t + LUT_STEP_SIZE
        }
        lut.to_h
      end

      def point_distance(point_1, point_2)
        Math.sqrt((point_1.x - point_2.x) ** 2 + (point_1.y - point_2.y) ** 2)
      end

      def find_closest(point, current_min_distance, t)
        step_size = LUT_STEP_SIZE / 100
        # this min step size reliably gives 4 d.p. accuracy, and descreaing it
        # really doesn't get any better accuracy...
        min_step_size = 0.01 / (2 * lut.size)
        min_t, max_t = [t - LUT_STEP_SIZE, 0].max, [t + LUT_STEP_SIZE, 1].min

        _, closest_t = find_closest_step(
          point: point, step_size: step_size, min_step_size: min_step_size,
          current_min_distance: current_min_distance, current_min_t: t,
          min_t: min_t, max_t: max_t
        )
        closest_t
      end

      def find_closest_step(point:, step_size:, min_step_size:, current_min_distance:, current_min_t:, min_t:, max_t:)
        return [current_min_distance, current_min_t] if step_size < min_step_size

        local_min_distance, local_min_t  = (min_t..max_t).step(step_size).map { |t|
          [point_distance(point, compute_point(t)), t]
        }.min_by { |distance, t| distance }

        if local_min_distance < current_min_distance
          find_closest_step(point: point, step_size: 2 * step_size / 100,
            min_step_size: min_step_size,
            current_min_distance: local_min_distance,
            current_min_t: local_min_t,
            min_t: local_min_t - step_size,
            max_t: local_min_t + step_size
          )
        else
          [current_min_distance, current_min_t]
        end
      end

      def de_casteljau
        @de_casteljau ||= Draught::DeCasteljau.new(world)
      end

      def extrema_axis_value_computer(axis, t)
        return start_point.send(axis) if t == 0
        return end_point.send(axis) if t == 1

        a, b, c, d = compute_abcd(t.to_f)

        compute_axis_value(axis, a, b, c, d)
      end

      def compute_axis_value(axis, a, b, c, d)
        (a * start_point.send(axis)) +
          (b * control_point_1.send(axis)) +
          (c * control_point_2.send(axis)) +
          (d * end_point.send(axis))
      end

      # @param t [Float]
      def compute_abcd(t)
        mt = 1 - t
        mt2 = mt * mt
        t2 = t * t
        a = mt2 * mt
        b = mt2 * t * 3
        c = mt * t2 * 3
        d = t * t2
        [a, b, c, d]
      end

      def transformed_instance(mapper)
        args = transform_args_hash.map(&mapper).to_h
        self.class.build(world, metadata: metadata, **args)
      end

      def transform_args_hash
        {start_point: start_point, cubic_bezier: cubic_bezier}
      end

      def all_points
        [start_point, control_point_1, control_point_2, end_point]
      end

      def extrema_points
        @extrema_points ||= extrema_t_values.map { |t| compute_point(t) }
      end

      def extrema_t_values
        @extrema_t_values ||= Extrema.t_values(world.tolerance, method(:extrema_axis_value_computer), self)
      end

      class Extrema
        attr_reader :tolerance, :axis_value_computer, :start, :control_1, :control_2, :last

        def self.t_values(tolerance, axis_value_computer, curve_segment)
          new(
            tolerance,
            axis_value_computer,
            curve_segment.start_point,
            curve_segment.control_point_1,
            curve_segment.control_point_2,
            curve_segment.end_point
          ).t_values
        end

        def initialize(tolerance, axis_value_computer, start, control_1, control_2, last)
          @tolerance, @axis_value_computer, @start, @control_1, @control_2, @last = tolerance, axis_value_computer, start, control_1, control_2, last
        end

        def t_values_for_axis(axis, result)
          a, b, c = derivative_bernstein_polynomial_form(axis)
          if a == 0 # start == end and c1 == c2
            vs = extrema_values_via_brute_force(axis, result)
            vs
          else
            quadratic_roots(a, b, c, result)
          end
        end

        def extrema_values_via_brute_force(axis, result)
          values = histogram(axis, 0, 1)
          [
            min_or_max_value_via_brute_force(axis, :min, values.first),
            min_or_max_value_via_brute_force(axis, :max, values.last),
          ].reject { |t|
            tolerance.within?(0, t) || tolerance.within?(1, t)
          }.each do |t|
            result << t
          end
        end

        def min_or_max_value_via_brute_force(axis, min_max_meth, histogram_value)
          values = histogram(axis, histogram_value.min_t, histogram_value.max_t)
          if values.permutation(2).all? { |a, b| tolerance.within?(a.value, b.value) }
            return histogram_value.min_t
          end
          min_or_max_value = values.send(:"#{min_max_meth}_by") { |v| v.value }
          min_or_max_value_via_brute_force(axis, min_max_meth, min_or_max_value)
        end

        HistogramValue = Struct.new(:min_t, :max_t, :value)

        def histogram(axis, min_t, max_t)
          step_size = (max_t - min_t) / 10.0
          steps = [min_t] + (1..9).to_a.map { |n|
            min_t + (step_size * n)
          } + [max_t]
          pairs = (0..(steps.length - 2)).map { |n|
            steps[n, 2]
          }.map { |min_t, max_t|
            HistogramValue.new(
              min_t, max_t,
              (axis_value_computer.call(axis, min_t) + axis_value_computer.call(axis, max_t)) / 2.0
            )
          }.sort_by { |hv| hv.value }
        end

        def derivative_bernstein_polynomial_form(axis)
          p0 = start.send(axis)
          p1 = control_1.send(axis)
          p2 = control_2.send(axis)
          p3 = last.send(axis)

          a = (-3.0 * p0) + (9.0 * p1) - (9.0 * p2) + (3.0 * p3)
          b = (6.0 * p0) - (12.0 * p1) + (6.0 * p2)
          c = (-3.0 * p0) + (3.0 * p1)

          [a, b, c]
        end

        # t = -b ± √(b² - 4ac) / 2a
        def quadratic_roots(a, b, c, result)
          sqrt_term = (b * b) - (4.0 * a * c)
          # bail if Math.sqrt would explode on a negative number
          return if sqrt_term < 0
          q = Math.sqrt(sqrt_term)
          result << (q - b)/(2.0 * a)
          result << (-b - q)/(2.0 * a)
        end

        def t_values
          result = [0.0, 1.0]
          t_values_for_axis(:x, result)
          t_values_for_axis(:y, result)
          result.select { |t| t >= 0 && t <= 1 }.sort.uniq
        end
      end
    end
  end
end